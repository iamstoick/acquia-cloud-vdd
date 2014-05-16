# == Define: drupal_db
#
# The drupal_db resource is a wrapper for a single Drupal database and database 
# user in the Percona Server database. The permissions for the database user are
# automatically configured.
#
# Optionally, the declaration may also declare include a remote source for the
# database, in which case it will be retrieved via mysqldump over SSH. To ensure
# that the database will not be inadvertently clobbered during provisioning, it
# will only be retrieved when the local database defined in database is empty
# (SHOW TABLES returns an empty set).
#
# === Parameters
#
# [*database*]
#   The name of the MySQL database to use. Defaults to the resource title.
# [*username*]
#   The name of the user that will manage this database.
# [*password*]
#   The password for the given username.
# [*su_user*]
#   Optional. The superuser account used to grant permissions. Defaults to root.
# [*su_pass*]
#   Optional. The password to the superuser account. Defaults to no password.
# [*src_ssh_user*]
#   Optional. The remote ssh user to use when connecting to the database.
# [*src_ssh_host*]
#   Optional. The host on which the remote database resides. Must be supplied
#   when retrieving a database from a remote host via SSH.
# [*src_ssh_known_host_key*]
#   Optional. The known_host key of the remote host to connect to when
#   retrieving a database from a remote host via SSH.
# [*src_db_name*]
#   Optional. The remote database to connect to when retrieving a database dump.
#   Must be supplied when retrieving a database from a remote host via SSH.
# [*src_db_user*]
#   Optional. The database user to use when connecting to the remote database.
#   Must be supplied when retrieving a database from a remote host via SSH.
# [*src_db_pass*]
#   Optional. The password to use when connecting to the remote database.
#
# === Examples
#
# Creates a new database called "mysite_db" (with the default character set and
# collation) from user@ssh.example.com via SSH, connecting to the database rmdb
# as remote_mysql_user:correcthorsebatterystaple. Note that the host is added to
# known_hosts using src_ssh_known_host_key.
#
# Locally, the database user mysite_db_admin will have all of the necessary
# permissions for this database.
# 
# undine_percona::database { 'mysite_db':
#   username => 'mysite_db_admin',
#   password => 'foobarbazbang',
#   su_user => 'superuser',
#   su_pass => 'correcthorsebatterystaple',
#   src_ssh_user => 'user',
#   src_ssh_host => 'ssh.example.com',
#   src_ssh_known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/ ...',
#   src_db_name => 'rmdb',
#   src_db_user => 'remote_mysql_user',
#   src_db_pass => 'correcthorsebatterystaple',
# }
#
define undine::drupal_db (
  $database = $title,
  $username,
  $password,
  $driver = 'mysql',
  $su_user = 'root',
  $su_pass = undef,
  $src_ssh_user = undef,
  $src_ssh_host = undef,
  $src_ssh_known_host_key = undef,
  $src_db_name = undef,
  $src_db_user = undef,
  $src_db_pass = undef,
) {
  if $driver == mysql {
    require undine_percona
    if $username == undef or $password == undef or $database == undef {
      fail('Username, password and database name must be defined for a Drupal database.')
    }
    undine_percona::database { "${database}": 
      su_user => $su_user,
      su_pass => $su_pass,
      src_ssh_user => $src_ssh_user,
      src_ssh_host => $src_ssh_host,
      src_ssh_known_host_key => $src_ssh_known_host_key,
      src_db_name => $src_db_name,
      src_db_user => $src_db_user,
      src_db_pass => $src_db_pass,
    }
    undine_percona::user { "${username}-${database}":
      username => "${username}",
      password => "${password}",
      grants => {
        "${database}" => [
          'SELECT',
          'INSERT',
          'UPDATE',
          'DELETE',
          'CREATE',
          'DROP',
          'INDEX',
          'ALTER',
          'LOCK TABLES',
          'CREATE TEMPORARY TABLES',
        ],
      },
      su_user => $su_user,
      su_pass => $su_pass,    
    }
  }
}
