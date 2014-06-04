# == Class: undine_apache
#
# The undine_apache class is responsible for the package management,
# installation, and configuration of the httpd server used by Undine. This
# includes core apache configuration, ports configuration, default site
# configuration, and Apache module installation and configuration.
#
# It should not be necessary to declare this class directly, as it will be 
# declared automatically by the undine class, which all Undine sites should use.
#
# Integration of PHP with Apache is provided in undine_apache_php.
# 
class undine_apache {

  exec { "apache-update-sources-file":
    command => '/usr/bin/apt-get update',
  }

  # Install package and dependencies.
  package { 'apache2':
    ensure => installed,
    require => Exec['apache-update-sources-file'],
  }

  # Manage core configuration files.

  file { '/etc/apache2/httpd.conf':
    path => '/etc/apache2/httpd.conf',
    ensure => file,
    require => Package['apache2'],
    source => 'puppet:///modules/undine_apache/httpd.conf',
  }
  file { '/etc/apache2/apache2.conf':
    path => '/etc/apache2/apache2.conf',
    ensure => file,
    require => Package['apache2'],
    source => 'puppet:///modules/undine_apache/apache2.conf',
  }
  file { '/etc/apache2/envvars':
    path => '/etc/apache2/envvars',
    ensure => file,
    require => Package['apache2'],
    source => 'puppet:///modules/undine_apache/envvars',
  }
  file { '/etc/apache2/ports.conf':
    path => '/etc/apache2/ports.conf',
    ensure => file,
    require => Package['apache2'],
    source => 'puppet:///modules/undine_apache/ports.conf',
  }
  file { '/etc/apache2/sites-available/default':
    path => '/etc/apache2/sites-available/default',
    ensure => file,
    require => Package['apache2'],
    source => 'puppet:///modules/undine_apache/default',
  }
  file { '/etc/apache2/sites-available/default-ssl':
    path => '/etc/apache2/sites-available/default-ssl',
    ensure => file,
    require => Package['apache2'],
    source => 'puppet:///modules/undine_apache/default-ssl',
  }

  # Enable core modules.

  undine_apache::httpd_mod { 'mod_ssl':
    mod_name => 'ssl',
    load_source => 'puppet:///modules/undine_apache/ssl.load',
    conf_source => 'puppet:///modules/undine_apache/ssl.conf',
  }

  undine_apache::httpd_mod { 'mod_rewrite':
    mod_name => 'rewrite',
    load_source => 'puppet:///modules/undine_apache/rewrite.load',
  }

  # Manage enabled site configuration.

  file { '/etc/apache2/sites-enabled/000-default':
    path => '/etc/apache2/sites-enabled/000-default',
    ensure => link,
    target => '/etc/apache2/sites-available/default',
    require => File['/etc/apache2/sites-available/default'],
  }
  file { '/etc/apache2/sites-enabled/000-default-ssl':
    path => '/etc/apache2/sites-enabled/000-default-ssl',
    ensure => link,
    target => '/etc/apache2/sites-available/default-ssl',
    require => File['/etc/apache2/sites-available/default-ssl'],
  }

  # Manage web root.

  file { '/var/www':
    path => '/var/www',
    ensure => directory,
    mode => 0664,
    require => Package['apache2'],
  }

  # Ensure lockfile owned by vagrant.

  file { '/var/lock/apache2':
    ensure => directory,
    owner => 'vagrant',
    require => Package['apache2'],
  }

  service { 'apache2':
    ensure => running,
    enable => true,
    require => File['/var/lock/apache2'],
  }
}
