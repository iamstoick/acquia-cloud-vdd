# == Class: undine_xhprof
#
# The undine_xhprof class is responsible for the installation and configuration
# of XHProf, a profiler for PHP applications. It is accessible via /xhprof_html,
# with the source installed at /usr/share/php53/xhprof-php53 (for modules such
# as Devel that require this information).
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_xhprof {

  undine_apt::ppa { 'skettler/php':
    ppa_user => 'skettler',
    ppa_name => 'php',
    source_list_d_filename => 'skettler-php-xhprof-precise.list',
    source_list_d_source => 'puppet:///modules/undine_php/skettler-php-xhprof-precise.list',
  }

  package { "php53-xhprof":
    ensure => installed,
  }

  package { "graphviz":
    ensure => installed,
  }

  undine_apache::misc_conf_file { "/etc/php53/conf.d/xhprof.ini":
    ensure => file,
    source => 'puppet:///modules/undine_xhprof/xhprof.ini',
    require => Package['php53-xhprof'],
  }

  file { "/var/www/xhprof_html":
    path => '/var/www/xhprof_html',
    ensure => link,
    target => '/usr/share/php53-xhprof/xhprof_html/',
    require => Package['php53-xhprof'],
  }

  # The vagrant user requires write permission on this directory.
  file { "/var/log/php53-xhprof":
    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant',
    mode => '0755',
    require => Package['php53-xhprof'],
  }
}
