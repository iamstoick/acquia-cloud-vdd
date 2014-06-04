# == Define: database
#
# The database resource is used by Undine to represent a single Percona Server
# database. This may represent a pristine database, or one imported via a local
# database dump.
#
# Optionally, the declaration may also declare include a remote source for the
# database, in which case it will be retrieved via mysqldump over SSH. To ensure
# that the database will not be inadvertently clobbered during provisioning, it
# will only be retrieved when the local database defined in db_name is empty 
# (SHOW TABLES returns an empty set).
#
# === Parameters
#
# [*db_name*]
#   The name of the MySQL database. Defaults to the resource title.
# [*src_path*]
#   Optional. The local source path of a SQL database dump to import. Mutually
#   exclusive with the src_ssh parameters.
# [*src_ssh_user*]
#   Optional. The remote ssh user to use when connecting to the database.
# [*src_hostname*]
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
# [*charset*]
#   Optional. The character set to use.
# [*collation*]
#   Optional. The default database collation to use.
# [*su_user*]
#   Optional. The database superuser name to use when creating the database.
#   Defaults to root.
# [*su_pass*]
#   Optional. The database superuser password to use when creating the database.
#   No password is set by default.
#
# === Examples
#
# Creates a new database called "mysite_db" with the latin1 character set, using
# the latin1_swedish_ci collation.
#
# undine_percona::database { 'mysite_db':
#   charset => 'latin1',
#   collation => 'latin1_swedish_ci',
# }
#
# Creates a new database called "mysite_db" (with the default character set and
# collation) from user@ssh.example.com via SSH, connecting to the database rmdb
# as remote_mysql_user:correcthorsebatterystaple. Note that the host is added to
# known_hosts using src_ssh_known_host_key.
#
#   undine_percona::database { 'mysite_db':
#     src_ssh_user => 'user',
#     src_hostname => 'ssh.example.com',
#     src_ssh_known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/ ...',
#     src_db_name => 'rmdb',
#     src_db_user => 'remote_mysql_user',
#     src_db_pass => 'correcthorsebatterystaple',
#   }
#
define undine_percona::database (
  $db_name = $title,
  $src_ssh_user = undef,
  $src_hostname = undef,
  $src_ssh_known_host_key = undef,
  $src_db_name = undef,
  $src_db_user = undef,
  $src_db_pass = undef,
  $charset = undef,
  $collation = undef,
  $su_user = root,
  $su_pass = undef,
) {
  include undine_percona

  if $su_pass != undef {
    $su_pass_flag = "-p${su_pass}"
  }
  else {
    $su_pass_flag = ''
  }

  if $charset != undef {
    $character_set = 'CHARACTER SET ${charset}'
  }
  else {
    $character_set = ''
  }

  if $collation != undef {
    $collate = 'COLLATE ${collation}'
  }
  else {
    $collate = ''
  }

  exec { "percona-database-${db_name}":
    unless => "/usr/bin/mysql -u${su_user} ${su_pass_flag} ${db_name}",
    command => "/usr/bin/mysql -u${su_user} ${su_pass_flag} -e \"CREATE DATABASE ${db_name} ${character_set} ${collate};\"",
    require => Service['mysql'],
  }

  if $src_hostname != undef and $src_path != undef {
    fail('A Percona database cannot define both an SSH and a local path source.')
  }

  if $src_path != undef {
    exec { "percona-database-${db_name}-import":
      onlyif => "/usr/bin/mysql -u${su_user} ${su_pass_flag} ${db_name} -e 'SHOW TABLES;' | wc -l | grep \"^0$\"",
      command => "mysqldump -u${su_user} ${su_pass_flag} ${db_name} < ${src_path}",
      require => [
        Service['mysql'],
        Exec["percona-database-${db_name}"],
      ],
    }
  }
  elsif $src_hostname != undef {
    if $src_ssh_known_host_key != undef and $src_hostname != undef {
      if !defined(Undine_ssh::Known_host["${src_hostname}"]) {
        undine_ssh::known_host { "${src_hostname}":
          key => $src_ssh_known_host_key,
        }
      }

      # Declare the relationship with chaining arrows, since we can't rely on
      # changing the initial state of the resource itself if it already exists.
      Undine_ssh::Known_host["${src_hostname}"] -> Exec["percona-database-${db_name}-import"]
    }

    if $src_db_pass != undef {
      $src_db_pass_flag = "-p${src_db_pass}"
    }
    else {
      $src_db_pass_flag = ''
    }

    if $src_hostname != undef and $src_db_name != undef and $src_db_user != undef {
      exec { "percona-database-${db_name}-import":
        onlyif => "/usr/bin/mysql -u${su_user} ${su_pass_flag} ${db_name} -e 'SHOW TABLES;' | wc -l | grep \"^0$\"",
        command => "/usr/bin/ssh ${src_ssh_user}@${src_hostname} 'mysqldump -u${src_db_user} ${src_db_pass_flag} ${src_db_name}' | /usr/bin/mysql -u${su_user} ${su_pass_flag} -D ${db_name}",
        require => [
          Service['mysql'],
          Exec["percona-database-${db_name}"],
        ],
      }
    }
  }

}
