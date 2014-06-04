# == Define: identity
#
# The identity defined type is responsible for the management of the primary Git
# identity in Undine. Specifically, it manages the Git globals user.name and
# user.email as through using the git config command.
#
# === Parameters
#
# [*git_name*]
#   The name to use to identify yourself to git. Defaults to the resouce title.
# [*email*]
#   The email address to use to identify yourself to git.
#
# === Examples
#
#   undine_git::identity { "Jane Smith":
#     email => 'jsmith@example.com',
#   }
#
define undine_git::identity (
  $git_name = $title,
  $email,
) {
  include undine_git
  
  exec { "git-identity-name-${git_name}":
    command => "/usr/bin/git config --global user.name ${git_name}",
    require => Package['git'],
  }
  exec { "git-identity-email-${email}":
    command => "/usr/bin/git config --global user.email ${email}",
    require => Package['git'],
  }
}
