# == Define: remote
#
# The remote defined type is responsible for the management of multiple remotes
# for Git repositories managed by in Undine.
#
# The remote defined type also provides a means of authenticating via SSH using
# a combination of agent forwarding to use your host environment's SSH keys
# (enabled in Undine by default) and manipulating the known_hosts file on the
# guest VM. To find a known_hosts entry on your host system, simply use
# `ssh-keygen -H -F git.example.com` to display the correct key to provide.
#
# === Parameters
#
# [*remote_name*]
#   The local name of the remote. Defaults to the resource title.
# [*remote_uri*]
#   The URI of the remote.
# [*repo_path*]
#   The destination path of the repository to add the remote to. This repository
#   must already exist in the filesystem.
# [*hostname*]
#   Optional. The hostname of the remote to whitelist when using SSH. Must be
#   defined along with known_host_key.
# [*known_host_key*]
#   Optional. The key of the remote to add to known_hosts for use with SSH. Must
#   be defined along with hostname.
#
# === Examples
#
# Usage via SSH with an associated known_host entry.
#
#   undine_git::remote { "example_remote":
#     remote_uri => 'user@git.example.com:example.git',
#     repo_path => '/var/www/example',
#     hostname => 'git.example.com',
#     known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/DTVaRmJW ...',
#   }
#
define undine_git::remote (
  $remote_name = $title,
  $remote_uri,
  $repo_path,
  $hostname = undef,
  $known_host_key = undef,
) {
  require undine_git
  
  if ($hostname != undef and $known_host_key == undef) or ($hostname == undef and $known_host_key != undef) {
    fail('If hostname is provided to a git remote, known_host_key must also be provided, and vice-versa.')
  }

  if $hostname != undef and $known_host_key != undef {
    include undine_ssh

    if !defined(Undine_ssh::Known_host["${hostname}"]) {
      undine_ssh::known_host { "${hostname}":
        key => $known_host_key,
      }
    }
    
    # Declare the relationship with chaining arrows, since we can't rely on
    # changing the initial state of the resource itself if it already exists.
    Undine_ssh::Known_host["${hostname}"] -> Exec["git-remote-${remote_name}-${repo_path}"]
  }
  # Apply the remote unless it already exists.
  exec { "git-remote-${remote_name}-${repo_path}":
    cwd => "${repo_path}",
    unless => "/usr/bin/git remote | /bin/grep '${remote_name}'",
    command => "/usr/bin/git remote add ${remote_name} ${remote_uri}",
  }
}
