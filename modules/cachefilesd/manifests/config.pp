class cachefilesd::config inherits cachefilesd {
  file { cachefilesd_config_file:
    ensure  => file,
    path    => $config,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('cachefilesd/cachefilesd.conf.erb'),
  }
}
