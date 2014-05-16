# == Define: virtualhost
#
# The virtualhost resource represents a single Apache VirtualHost 
# configuration, triggering a restart of the Apache server whenever it is 
# modified. The configuration is stored in sites-available, then enabled using
# a2ensite.
#
# === Parameters
#
# [*server_name*]
#   The name to provide to the VirtualHost's ServerName directive. Defaults to
#   the resouce title.
# [*document_root*]
#   The DocumentRoot from which to serve files.
#
# === Examples
#
# undine_apache::virtualhost { 'mysite.local':
#   document_root => '/var/www/html/mydir',
# }
#
define undine_apache::virtualhost(
  $document_root,
  $server_name = $title,
) {
  include ::undine_apache

  $server_filename = get_server_filename($server_name)

  file { "/etc/apache2/sites-available/${server_filename}":
    mode => '0644',
    content => template('undine_apache/virtualhost.erb'),
    require => Package['apache2'],
    notify => Exec["/usr/sbin/a2ensite ${server_filename}"],
  }

  exec { "/usr/sbin/a2ensite ${server_filename}":
    command => "/usr/sbin/a2ensite ${server_filename}",
    require => File["/etc/apache2/sites-available/${server_filename}"],
    notify => Service['apache2'],
  }
}
