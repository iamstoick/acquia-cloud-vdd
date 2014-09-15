# Source: https://launchpad.net/~james-page/+archive/ubuntu/junk
#
class undine_memcached::package {

  undine_apt::ppa { 'james-page/memcached':
    ppa_user => 'travis-ci',
    ppa_name => 'memcached',
    source_list_d_filename => 'memcached-ppa-precise.list',
    source_list_d_source => 'puppet:///modules/undine_memcached/memcached-ppa-precise.list',
  }

  package { 'memcached':
    require => Undine_apt::Ppa['james-page/memcached'],
    ensure => installed,
  }

  package { "php53-memcache":
    ensure => installed,
    notify => [ Service['apache2'], ],
  }

}
