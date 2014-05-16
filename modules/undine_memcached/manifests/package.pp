# Source: https://launchpad.net/~travis-ci/+archive/memcached-sasl
#
class undine_memcached::package {

  undine_apt::ppa { 'travis-ci/memcached-sasl':
    ppa_user => 'travis-ci',
    ppa_name => 'memcached-sasl',
    source_list_d_filename => 'memcached-ppa-precise.list',
    source_list_d_source => 'puppet:///modules/undine_memcached/memcached-ppa-precise.list',
  }

  package { 'memcached':
    require => Undine_apt::Ppa['travis-ci/memcached-sasl'],
    ensure => installed,
  }

  package {'php5-memcache':
    ensure => present,
    notify => [ Service['apache2'], ],
  }
}
