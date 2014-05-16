# == Class: undine_percona
#
# The undine_percona class is responsible for the installation and configuration
# of Percona Server, a drop-in replacement for MySQL. Installation is done via
# the signed packages made available on the Percona website.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_percona {

  # Add Percona PGP key.

  exec { "percona-add-apt-key":
    unless => '/usr/bin/apt-key list | grep \'Percona MySQL Development Team\'',
    command => '/usr/bin/apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A'
  }

  # Add Percona repositories to sources list.

  file { "/etc/apt/sources.list.d/percona.list":
    path => '/etc/apt/sources.list.d/percona.list',
    ensure => file,
    source => 'puppet:///modules/undine_percona/percona.list',
  }

  # Update sources list cache with Percona sources list.

  exec { "percona-source-list-update":
    command => '/usr/bin/apt-get update',
    subscribe => [
      File['/etc/apt/sources.list.d/percona.list'],
      Exec['percona-add-apt-key'],
    ],
  }

  # Install packages.

  package { "percona-server-server-5.5":
    ensure => installed,
    require => Exec['percona-source-list-update'],
  }
  package { "percona-server-client-5.5":
    ensure => installed,    
    require => Exec['percona-source-list-update'],
  }

  # Manage configuration.

  file { "/etc/mysql/my.cnf":
    path => '/etc/mysql/my.cnf',
    ensure => file,
    mode => 0600,
    source => 'puppet:///modules/undine_percona/my.cnf',
    require => Package['percona-server-server-5.5'],
  }

  # Resize InnoDB log files from stock to 64M if necessary.

  exec { "percona-resize-innodb-logs":
    unless => '/usr/bin/test `/usr/bin/stat /var/lib/mysql/ib_logfile0 --format \'%s\'` -eq 67108864',
    command => '/bin/rm /var/lib/mysql/ibdata*; /bin/rm /var/lib/mysql/ib_logfile*',
    require => Package['percona-server-server-5.5'],
  }

  # Enable service.

  service { "mysql":
    ensure => running,
    subscribe => [
      File['/etc/mysql/my.cnf'],
      Exec['percona-resize-innodb-logs'],
    ],
  }
}
