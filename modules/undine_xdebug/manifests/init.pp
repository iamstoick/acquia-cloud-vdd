# == Class: undine_xdebug
#
# The undine_xdebug class is responsible for the installation and configuration
# of XDebug, a debugger for PHP. It is configured to connect to a debugger
# listening on 10.0.2.2:9000, the default IP of the host system in VirtualBox.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_xdebug {
  require undine_php

  package { "php53-xdebug":
    ensure => installed,
  }

  undine_apache::misc_conf_file { "/etc/php53/conf.d/xdebug.ini":
    ensure => file,
    source => 'puppet:///modules/undine_xdebug/xdebug.ini',
    require => Package['php53-xhprof'],
  }
}
