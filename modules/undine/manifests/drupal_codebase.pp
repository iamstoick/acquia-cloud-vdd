# == Define: drupal_codebase
#
# A resource representing a single Drupal codebase in Undine, which may or may 
# not be shared in a multisite configuration.
#
# Because Drupal codebases are home to one or more sites each with their own
# database, those looking to use Undine to create a fully-functional Drupal site
# must also declare an undine::drupal_site associated with the codebase. See the
# usage of undine:drupal_site for more information and examples.
#
# === Parameters
#
# [*path*]
#   The destination path in which the site will be created. Defaults to the
#   resource title.
# [*core_version*]
#   The version of Drupal core to use when creating the site if it doesn't
#   exist. May be a major version (7), a minor version (7.24), or a development
#   branch (7.x). Mutually exclusive with git_source.
# [*git_source*]
#   The full URI of the Git repository of the source code to use. Mutually
#   exclusive with core_version.
# [*branch*]
#   Optional. The branch to checkout of the Git repository. Defaults to HEAD.
# [*hostname*]
#   Optional. The hostname of the repository to whitelist when using Git with
#   SSH. Must be defined along with known_host_key.
# [*known_host_key*]
#   Optional. The key of the repository to add to known_hosts for use with Git 
#   via SSH. Must be defined along with hostname.
# [*remotes*]
#   Optional. A hash of remotes for this repository, keyed by the name of the
#   remote with a hash representing the remote as a value. These hash keys and
#   values are the same as those used in undine_git::remote (with repo_path
#   automatically populated using the value of path).
#
# === Examples
#
# Retrieving the lastest stable version of Drupal 7.
#
#   undine::drupal_codebase { '/var/www/example':
#     core_version => '7',
#   }
#
# Retrieving the lastest development branch of Drupal 7.
#
#   undine::drupal_codebase { '/var/www/example':
#     core_version => '7.x',
#   }
#
# Retrieving a specific minor release of Drupal core.
#
#   undine::drupal_codebase { '/var/www/example':
#     core_version => '7.14',
#   }
#
# Retrieving a third-party Drupal distribution via Git.
#
#   undine::drupal_codebase { '/var/www/example':
#     git_source => "http://git.example.com/project/example.git"
#   }
#
# Retrieving a third-party distribution via SSH, with a defined branch and an
# associated known_host entry. Also declares an additional remote for the repo.
#
#   undine::drupal_codebase { '/var/www/example':
#     git_source => "ssh://maintainer@git.example.com/project/example.git"
#     branch => '7.x-1.x',
#     hostname => 'git.example.com',
#     known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/DTVaRmJW ...',
#     remotes => {
#        "example_remote" => {
#          remote_uri => 'user@git2.example.com:example.git',
#          hostname => 'git2.example.com',
#          known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/DTVaRmJW ...',
#       },
#     },
#   }
# 
define undine::drupal_codebase (
  $path = $title,
  $core_version = undef,
  $git_source = undef,
  $branch = undef,
  $hostname = undef,
  $known_host_key = undef,
  $remotes = undef,
) {
  # Retrieve the named version of Drupal core (7, 7.x, 7.24).
  if $core_version != undef {
    $core_project = "drupal-${core_version}"
  }
  else {
    $core_project = 'drupal'
  }

  $project_name = get_project_name($path)
  $basepath = get_project_basepath($path)

  if $core_version != undef and $git_source == undef {
    require undine_drush

    exec { "/usr/bin/drush dl ${core_project} --destination=\'${basepath}\' --drupal-project-rename=\'${project_name}\'":
      unless => "/bin/ls /var/www/${project_name}",
      command => "/usr/bin/drush dl ${core_project} --destination=\'${basepath}\' --drupal-project-rename=\'${project_name}\'",
      alias => "drupal-dl-${core_project}-as-${project_name}",
    }
  }
  elsif $core_version == undef and $git_source != undef {
    undine_git::repository { "${git_source}":
      branch => $branch,
      path => $path,
      hostname => $hostname,
      known_host_key => $known_host_key,
      remotes => $remotes,
    }
  }
  else {
    fail('Either core_version or git_source must be set when declaring a Drupal codebase.')
  }
}
