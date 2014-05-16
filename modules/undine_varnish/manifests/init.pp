# Author: Marji Cermak <marji@morpht.com>
#
# == Class: undine_varnish
#
# The undine_varnish class is responsible for the installation of varnish in Undine.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_varnish ( $version = '3.0' ) {

  # Installs the GPG key
  exec { 'import-key':
    path    => '/bin:/usr/bin',
    command => 'curl http://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add -',
    unless  => 'apt-key list | grep servergrove-ubuntu-precise',
    require => Package['curl'],
  }

  # Creates the source file for the ServerGrove repository
  file { 'varnish.repo':
    path    => '/etc/apt/sources.list.d/varnish.list',
    ensure  => present,
    content => "deb http://repo.varnish-cache.org/ubuntu/ precise varnish-${version}",
    require => Exec['import-key'],
  }

  exec { "varnish-update-sources-file":
    command => '/usr/bin/apt-get update',
    require => File['varnish.repo'],
  }

  package { 'varnish':
    ensure => installed,
    require => Exec['varnish-update-sources-file'],
  }

  file { '/etc/varnish/default.vcl':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/undine_varnish/default.vcl',
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  file { '/etc/default/varnish':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/undine_varnish/varnish',
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  service { 'varnish':
    enable   => true,
    ensure   => running,
    require  => Package['varnish'],
  }

}
