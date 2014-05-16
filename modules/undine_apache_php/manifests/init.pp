# == Class: undine_apache_php
#
# The undine_apache_php class is responsible for the package management,
# installation, and configuration of the php53 module for httpd in Undine.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
# Provisioning for Apache and PHP are managed by undine_apache and undine_php,
# respectively.
#
class undine_apache_php {
  require undine_php

  package { "libapache2-mod-php53":
    ensure => installed,
  }

  undine_apache::httpd_mod { "php53":
    mod_name => 'php53',
    load_source => 'puppet:///modules/undine_apache_php/php53.load',
    conf_source => 'puppet:///modules/undine_apache_php/php53.conf',
    require => Package['libapache2-mod-php53'],
  }
}
