class undine_memcached::service {

  service {'memcached':
    ensure => running,
  }

}
