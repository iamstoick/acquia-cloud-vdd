class cachefilesd::install inherits cachefilesd {
  package { "$package_name":
    ensure => $package_ensure,
    name   => $package_name,
  }

}
