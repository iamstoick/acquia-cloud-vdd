class cachefilesd::params {
  $service_enable = true
  $service_ensure = 'running'
  $service_manage = true
  $package_ensure = 'installed'
  $cachetag = 'nfscache'
  $culltable = '12'
  $disablecull = false
  $debugcache = '0'
  $brun = '10%'
  $frun = '10%'
  $bcull = '7%'
  $fcull = '7%'
  $bstop = '3%'
  $fstop = '3%'

  case $::osfamily {
    'RedHat'    : {
      $package_name = ['cachefilesd']
      $service_name = 'cachefilesd'
      $config = '/etc/cachefilesd.conf'
      $hasstatus = true
      $hasrestart = true
      $cachedir = '/var/cache/fscache'
      $secctx = 'system_u:system_r:cachefiles_kernel_t:s0'
    }
    'Debian'    : {
      $package_name = ['cachefilesd']
      $service_name = 'cachefilesd'
      $config = '/etc/cachefilesd.conf'
      $hasstatus = true
      $hasrestart = true
      $cachedir = '/var/cache/fscache'
      $secctx = 'system_u:system_r:cachefiles_kernel_t:s0'
    }
    'SuSE'      : {
      $package_name = ['cachefilesd']
      $service_name = 'cachefilesd'
      $config = '/etc/cachefilesd.conf'
      $hasstatus = true
      $hasrestart = true
      $cachedir = '/var/cache/fscache'
      $secctx = 'system_u:system_r:cachefiles_kernel_t:s0'
    }
    'Gentoo'    : {
      $package_name = ['cachefilesd']
      $service_name = 'cachefilesd'
      $config = '/etc/cachefilesd.conf'
      $hasstatus = true
      $hasrestart = true
      $cachedir = '/var/cache/fscache'
      $secctx = 'system_u:system_r:cachefiles_kernel_t:s0'
    }
    'Archlinux' : {
      $package_name = ['cachefilesd']
      $service_name = 'cachefilesd'
      $config = '/etc/cachefilesd.conf'
      $hasstatus = true
      $hasrestart = true
      $cachedir = '/var/cache/fscache'
      $secctx = 'system_u:system_r:cachefiles_kernel_t:s0'
    }
    'Mandrake'  : {
      $package_name = ['cachefilesd']
      $service_name = 'cachefilesd'
      $config = '/etc/cachefilesd.conf'
      $hasstatus = true
      $hasrestart = true
      $cachedir = '/var/cache/fscache'
      $secctx = 'system_u:system_r:cachefiles_kernel_t:s0'
    }
    default     : {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
}
