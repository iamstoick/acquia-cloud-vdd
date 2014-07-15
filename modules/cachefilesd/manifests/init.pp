class cachefilesd (
  $service_enable   = $cachefilesd::params::service_enable,
  $service_ensure   = $cachefilesd::params::service_ensure,
  $service_manage   = $cachefilesd::params::service_manage,
  $package_ensure   = $cachefilesd::params::package_ensure,
  $hasrestart       = $cachefilesd::params::hasrestart,
  $hasstatus        = $cachefilesd::params::hasstatus,
  $cachedir         = $cachefilesd::params::cachedir,
  $cachetag         = $cachefilesd::params::cachetag,
  $culltable        = $cachefilesd::params::culltable,
  $disablecull      = $cachefilesd::params::disablecull,
  $debugcache       = $cachefilesd::params::debugcache,
  $brun             = $cachefilesd::params::brun,
  $frun             = $cachefilesd::params::frun,
  $bcull            = $cachefilesd::params::bcull,
  $fcull            = $cachefilesd::params::fcull,
  $bstop            = $cachefilesd::params::bstop,
  $fstop            = $cachefilesd::params::fstop,
  $secctx           = $cachefilesd::params::secctx) inherits cachefilesd::params {
  include 'stdlib'
  validate_bool($service_enable, $service_manage, $hasstatus, $hasrestart, $disablecull)
  validate_absolute_path($config, $cachedir)
  validate_string($service_ensure, $package_ensure, $binname, $cachetag)

  anchor { 'cachefilesd::begin': } ->
  class { '::cachefilesd::install': } ->
  class { '::cachefilesd::config': } ~>
  class { '::cachefilesd::service': } ->
  anchor { 'cachefilesd::end': }
}
