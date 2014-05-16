# == Class: undine_apt
#
# The undine_apt class is responsible for the installation of the
# python-software-properties package, necessary for the management of PPAs.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by declaring a undine_apt::ppa resource.
#
class undine_apt {

  exec { "apt-update":
    command => '/usr/bin/apt-get update',
  }

  package { "python-software-properties":
    ensure => installed,
    #require => Exec['apt-update'],
  }
}
