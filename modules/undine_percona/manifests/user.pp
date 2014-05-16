# == Define: user
#
# The user resource is used by Undine to represent a single database user in the
# Percona Server RDBMS.
#
# === Parameters
#
# [*username*]
#   The name of the user to create. Defaults to the resource title.
# [*password*]
#   The password for the given user.
# [*grants*]
#   Optional. A set of hashes with database names as keys, and array values
#   containing the strings of each permission (SELECT, UPDATE, etc.) that should
#   be assigned to the corresponding database. The proper format is further
#   illustrated in the examples.
# [*su_user*]
#   Optional. The superuser account used to grant permissions. Defaults to root.
# [*su_pass*]
#   Optional. The password to the superuser account. Defaults to no password.
#
# === Examples
#
# undine_percona::user { 'mysite_db_user':
#   password => 'correcthorsebatterystaple',
#   grants => {
#     'mysite_db' => [
#       'SELECT', 
#       'INSERT', 
#       'UPDATE',
#       'DELETE',
#     ],
#     'other_db' => ['ALL'],
#   },
# }
#
define undine_percona::user (
  $password,
  $username = $title,
  $grants = undef,
  $su_user = root,
  $su_pass = undef,
) {
  include undine_percona

  if $password == undef {
    fail('Password must be defined for a database user.')
  }
  if $su_pass != undef {
    $su_pass_flag = "-p${su_pass}"
  }
  else {
    $su_pass_flag = ''
  }
  exec { "percona-user-${title}":
    unless => "/usr/bin/mysql -u${username} -p${password}",
    command => "/usr/bin/mysql -u${su_user} ${us_pass_flag} -e \"CREATE USER '${username}'@'localhost' IDENTIFIED BY '${password}';\"",
    require => Service['mysql'],
  }
  
  # TODO: Add condition to confirm structure of grants hash.
  if $grants != undef {
    $grant_resources = convert_grants_to_resources($username, $grants, $su_user, $su_pass)
    $grant_resources_defaults = {
      require => Exec["percona-user-${title}"],
    }
    create_resources(exec, $grant_resources, $grant_resources_defaults)
  }
}
