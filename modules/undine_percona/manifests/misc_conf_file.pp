# == Define: misc_conf_file
#
# The misc_conf_file resource represents a single configuration file to manage,
# triggering an restart of the Percona server when modified. Fundamentally, this
# is a wrapper around a file resource that notifies the Percona service.
#
# === Parameters
#
# [*content*]
#   The raw content to use for the file, as a string. Mutually exclusive with
#   source.
# [*source*]
#   A source file, which will be copied into place on the local system, with the
#   same usage as the file resource. Mutually exclusive with content.
# [*ensure*]
#   Optional. Whether and what type of file should exist, as defined by the file
#   resource, with the exception of link. Defaults to file.
# [*path*]
#   Optional. The destination path of the file. Defaults to the resource title.
#
# === Examples
#
#   undine_percona::misc_conf_file { '/etc/mysql/conf.d/override.cnf':
#     source => 'puppet:///modules/my_percona_module/override.cnf',
#   }
#
define undine_percona::misc_conf_file (
  $content = undef,
  $source = undef,
  $ensure = file,
  $path = $title,
) {
  include ::undine_percona
  if $content and $source {
    fail('You may not supply both content and source parameters to a Percona-managed config file.')
  }
  elsif $content == undef and $source == undef {
    fail('You must supply either the content or source parameter to a Percona-managed config file.')
  }
  if $path == 'link' {
    fail('Miscellaneous Percona configuration files may not be symbolic links.')
  }

  file { "${path}":
    ensure => $ensure,
    owner => 'root',
    group => 'root',
    mode => '640',
    content => $content,
    source => $source,
    notify => Service['mysql'],
    require => Package['percona-server-server-5.5'],
  }
}
