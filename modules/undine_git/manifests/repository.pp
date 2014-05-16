# == Define: repository
#
# The repository defined type is responsible for the management of Git
# repositories in Undine.
#
# The repository defined type also provides a means of authenticating via SSH
# using a combination of agent forwarding to use your host environment's SSH
# keys (enabled in Undine by default) and manipulating the known_hosts file
# on the guest VM. To find a known_hosts entry on your host system, simply use
# `ssh-keygen -H -F git.example.com` to display the correct key to provide.
#
# === Parameters
#
# [*directory*]
#   The destination directory to be used by git clone. This directory must not
#   already exist in the filesystem.
# [*repo_uri*]
#   Optional. The URI of the repository to clone. Defaults to the resource
#   title.
# [*branch*]
#   Optional. The branch to checkout. Defaults to HEAD.
# [*known_host_name*]
#   Optional. The hostname of the repository to whitelist when using SSH. Must
#   be defined along with known_host_key.
# [*known_host_key*]
#   Optional. The key of the repository to add to known_hosts for use with SSH.
#   Must be defined along with known_host_name.
# [*remotes*]
#   Optional. A hash of remotes for this repository, keyed by the name of the
#   remote with a hash representing the remote as a value. These hash keys and
#   values are the same as those used in undine_git::remote (with repo_path
#   automatically populated using the value of directory).
#
# === Examples
#
# Simple usage via HTTP.
#
# undine_git::repository { "http://git.example.com/project/example.git":
#   directory => '/var/www/example',
# }
#
# Usage via SSH with a defined branch and associated known_host entry. Also
# declares an additional remote to use with the repository once cloned.
#
# undine_git::repository { "ssh://user@git.example.com/project/example.git":
#   branch => '7.x-1.x',
#   directory => '/var/www/example',
#   known_host_name => 'git.example.com',
#   known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/DTVaRmJW ...',
#   remotes => {
#      "example_remote" => {
#        remote_uri => 'user@git.example.com:example.git',
#        known_host_name => 'git.example.com',
#        known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/DTVaRmJW ...',
#     },
#   },
# }
#
define undine_git::repository (
  $directory,
  $repo_uri = $title,
  $branch = undef,
  $known_host_name = undef,
  $known_host_key = undef,
  $remotes = undef,
) {
  require undine_git

  if ($known_host_name != undef and $known_host_key == undef) or ($known_host_name == undef and $known_host_key != undef) {
    fail('If known_host_name is provided to a git repository, known_host_key must also be provided, and vice-versa.')
  }

  if ($branch != undef) {
    $branch_flag = "--branch ${branch}"
  }
  else {
    $branch_flag = ''
  }

  if $known_host_name != undef and $known_host_key != undef {
    include undine_ssh

    if !defined(Undine_ssh::Known_host["${known_host_name}"]) {
      undine_ssh::known_host { "${known_host_name}":
        key => $known_host_key,
      }
    }

  # Declare the relationship with chaining arrows, since we can't rely on
  # changing the initial state of the resource itself if it already exists.
  Undine_ssh::Known_host["${known_host_name}"] -> Exec["git-clone-to-${directory}"]
  }
  exec { "git-clone-to-${directory}":
    unless => "/bin/ls ${directory}/.git",
    command => "/usr/bin/git clone -v ${branch_flag} ${repo_uri} ${directory}",
  }
  exec { "git-clone-to-${directory}-ownership":
    command => "/bin/chown -R ${host_uid}:20 ${directory}",
    require => Exec["git-clone-to-${directory}"],
    logoutput => $logoutput,
  }
  exec { "git-clone-to-${directory}-permissions":
    command => "/bin/chmod -R 775 ${directory}",
    require => Exec["git-clone-to-${directory}-ownership"],
    logoutput => $logoutput,
  }

  # Set default path and dependency information for remotes.
  $defaults = {
    'require' => Exec["git-clone-to-${directory}"],
    'repo_path' => "${directory}",
  }
  create_resources(undine_git::remote, $remotes, $defaults)
}
