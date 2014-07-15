# brentschler-cachefilesd

[![Build Status](
https://api.travis-ci.org/phoenixv/cachefilesd.png?branch=master)](https://travis-ci.org/phoenixv/cachefilesd)


#### Table of Contents

1. [Overview](#overview)
2. [Compatability](#compatability)
3. [Dependencies](#dependencies)
4. [Examples](#examples)
5. [Parameters](#parameters)
6. [Limitations](#limitations)
7. [License](#license)
8. [Development](#development)


# Overview

This Puppet module is designed to facilitate the installation and configuration of [cachefilesd](http://people.redhat.com/dhowells/fscache/).
The primary scope includes installing the package on the system and populating the config file with the appropriate values.

Reasonable defaults have been set, so including the module with no settings will allow it to run.

## Compatability

This module has been tested to work with puppet 3.0.x and greater

This module has been tested to work on the following systems.

* Fedora 20
* CentOS 6.x
* SLES 11

Sections for all Linux versions reported by osfamily are present in params.pp and should
work as all distros seem to repackage the RedHat package exactly as it is. If you have
success with this module on an un-tested distro please [report it](https://github.com/phoenixv/cachefiled)
so the documentation may be updated.

It should work on all Linux systems supported by puppet as it uses a single configuration file
in a consistent location.

## Dependencies

- [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)


# Examples

*With traditional puppet node configuration:*

```ruby
class { 'cachefilesd':
  service_manage      => true,
  service_enable      => true,
  service_ensue       => 'running'
  package_ensue       => 'latest'
  brun				  => '20%'
  frun                => '20%'
  bcull               => '20%'
  fcull				  => '10%'
  bstop				  => '5%'
  fstop               => '5%'
}
```

*With heira:*

```yaml
---
classes:
  - cachefilesd

cachefilesd::service_manage: true
cachefilesd::service_enable: true
cachefilesd::service_ensure: 'running'
cachefilesd::package_ensure: 'latest'
cachefilesd::brun: '20%'
cachefilesd::frun: '20%'
cachefilesd::bcull: '10%'
cachefilesd::fcull: '10%'
cachefilesd::bstop: '5%'
cachefilesd::fstop: '5%'
```


# Parameters

All Parameters are optional, if none are specified the defaults will use all but 10% of the drive on
which the cache resides.

|Variable	| Default value| Description|
|:---------:|:-------------:|:-----------|
| brun   	 | 10% 			| Amount of free space (in blocks) required for free running operation. |
| frun   	 | 10% 			| Number of free files on the filesystem required for free running operation.
| bcull  	 |  7% 			| Amount of free space (in blocks) remaining at which cachefilesd culls the cache.
| fcull   	 |  7% 			| Same as bcull but for free files remaining.
| bstop   	 |  3% 			| Amount of free space (in blocks) remaining at which cachefilesd stops writing new files.
| fstop   	 |  3% 			| Same as bstop but for free files remaining.
| cachedir   |/var/run/fscache| Location for the cache. It is not recommended to change this, particularly if selinux is enabled.
| disablecull| false		| Turns off culling, may be useful in some cases but generally should be left alone.
| debugcache |0				| See **man cachefilesd.conf** for values.
| culltable  |12			| See **man cachefilesd.conf** for values.
| secctx 	 |*OS dependant*| SElinux context to run under.

# Limitations

The module does not check the underlying file system for correct mount options and features required
by cachefilesd to run..

# License

[GPL v2](http://www.gnu.org/licenses/gpl-2.0.html)

# Development

Please [report issues](https://github.com/phoenixv/cachefiled) or [submit a pull request](https://github.com/phoenixv/cachefilesd/pulls).
