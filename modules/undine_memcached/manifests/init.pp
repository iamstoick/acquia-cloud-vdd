# == Class: undine_memcached
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_memcached (
  $enable_memcached = 'yes',
  $log_file         = '/var/log/memcached.log',
  $memory_max       = 64,
  $listen_port      = 11211,
  $listen_ip        = '127.0.0.1',
  $memcache_user    = 'memcache',
  $connection_limit = 1024
) {

  class {'undine_memcached::package':
    notify => Class['undine_memcached::service'],
  }

  class {'undine_memcached::config':
    notify  => Class['undine_memcached::service'],
    require => Class['undine_memcached::package'],
  }

  class {'undine_memcached::service':
    require => Class['undine_memcached::config'],
  }

}
