class undine_memcached::config {

  file {'/etc/default/memcached':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    content => template('undine_memcached/default.erb'),
  }

  file {'/etc/memcached.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    content => template('undine_memcached/memcached.conf.erb'),
  }

}
