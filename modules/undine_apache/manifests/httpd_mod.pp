# == Define: httpd_mod
#
# The httpd_mod resource represents a single Apache module to manage, triggering
# a restart of the Apache server whenever its configuration is modified. 
#
# === Parameters
#
# [*mod_name*]
#   The name of the Apache module.
# [*load_content*]
#   The raw content to use for the load configuration file, as a string.
#   Mutually exclusive with load_source.
# [*load_source*]
#   A source file for the load configuration, which will be copied into place
#   on the local system, with the same usage as the file resource. Mutually
#   exclusive with load_content.
# [*conf_content*]
#   Optional. The raw content to use for the main configuration file (if any),
#   as a string. Mutually exclusive with conf_source.
# [*conf_source*]
#   Optional. A source file for the main configuration (if any), which will be
#   copied into place on the local system, with the same usage as the file 
#   resource. Mutually exclusive with conf_content.
# [*enabled*]
#   Optional. Whether the module should be enabled. Defaults to true.
#
# === Examples
#
#   undine_apache::http_mod { 'mod_rewrite':
#     mod_name => 'rewrite',
#     load_source => 'puppet:///modules/my_rw_module/rewrite.load',
#   }
#
#   undine_apache::http_mod { 'mod_ssl':
#     mod_name => 'ssl',
#     load_source => 'puppet:///modules/my_ssl_module/ssl.load',
#     conf_source => 'puppet:///modules/my_ssl_module/ssl.conf',
#   }
#
define undine_apache::httpd_mod (
  $mod_name,
  $load_content = undef,
  $load_source = undef,
  $conf_content = undef,
  $conf_source = undef,
  $enabled = true,
) {
  include ::undine_apache

  if ($enabled) {
    exec { "/usr/sbin/a2enmod ${mod_name}":
      unless => "/usr/sbin/apache2ctl -M | grep ${mod_name}",
      command => "/usr/sbin/a2enmod ${mod_name}",
      require => Package['apache2'],
    }
    $file_ensure = file
    $link_ensure = link
  }
  elsif ($enabled == false) {
    exec { "/usr/sbin/a2dismod ${mod_name}":
      onlyif => "/usr/sbin/apache2ctl -M | grep ${mod_name}",
      command => "/usr/sbin/a2dismod ${mod_name}",
      require => Package['apache2'],
    }
    $file_ensure = absent
    $link_ensure = absent
  }
  else {
    fail('The enabled parameter for an httpd module must be true or false.')
  }

  if ($load_content and $load_source) or ($conf_content and $conf_source) {
    fail('You may not supply both content and source parameters to an httpd module config file.')
  }

  if ($load_content != undef or $load_source != undef) {
    file { "/etc/apache2/mods-available/${mod_name}.load":
      ensure => $file_ensure,
      owner => 'root',
      group => 'root',
      mode => '640',
      content => $load_content,
      source => $load_source,
      require => Exec["/usr/sbin/a2enmod ${mod_name}"],
      notify => Service['apache2'],
    }
    file { "/etc/apache2/mods-enabled/${mod_name}.load":
      path => "/etc/apache2/mods-enabled/${mod_name}.load",
      ensure => $link_ensure,
      target => "/etc/apache2/mods-available/${mod_name}.load",
      require => File["/etc/apache2/mods-available/${mod_name}.load"],
    }
  }
  if ($conf_content != undef or $conf_source != undef) {
    file { "/etc/apache2/mods-available/${mod_name}.conf":
      ensure => $file_ensure,
      owner => 'root',
      group => 'root',
      mode => '640',
      content => $conf_content,
      source => $conf_source,
      require => Exec["/usr/sbin/a2enmod ${mod_name}"],
      notify => Service['apache2'],
    }
    file { "/etc/apache2/mods-enabled/${mod_name}.conf":
      path => "/etc/apache2/mods-enabled/${mod_name}.conf",
      ensure => $link_ensure,
      target => "/etc/apache2/mods-available/${mod_name}.conf",
      require => File["/etc/apache2/mods-available/${mod_name}.conf"],
    }
  }
}
