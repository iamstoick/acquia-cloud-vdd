# == Class: undine_php
#
# The undine_php class is responsible for the installation and configuration
# of PHP. Installation is done via the signed packages made available on the
# aoe PPA.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_php {

  undine_apt::ppa { 'aoe/php':
    ppa_user => 'aoe',
    ppa_name => 'php',
    source_list_d_filename => 'aoe-php-precise.list',
    source_list_d_source => 'puppet:///modules/undine_php/aoe-php-precise.list',
  }

  # Install PHP 5.3 package.
  package { "php53":
    ensure => installed,
    require => Undine_apt::Ppa['aoe/php'],
  }
  package { "php53-pear":
    ensure => installed,
    require => Undine_apt::Ppa['aoe/php'],
  }
}

