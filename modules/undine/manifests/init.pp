# == Class: undine
#
# The undine class is a wrapper for the the other components of the Undine VM,
# in addition to providing other minor system-level configuration (such as using
# a more informative motd).
#
# === Examples
#
# The primary use of the Undine class is to encapuslate basic provisioning for
# the VM. It is intended to be declared in Puppet modules in the ./sites 
# directory using the require syntax, typically followed by a single 
# undine::drupal_codebase and one or more undine::drupal_site resources.
#
class undine { 
  require undine_php
  require undine_apache
  require undine_apache_php
  require undine_percona
  require undine_git
  require undine_ssh
  require undine_drush
  require undine_xhprof
  require undine_xdebug
  require undine_curl
  require undine_vim
  require undine_varnish
  require undine_memcached
  require undine_sendmail

  file { "/etc/motd":
    path => '/etc/motd',
    ensure => file,
    source => 'puppet:///modules/undine/motd',
  }

  # NFS configuration for those hosts that choose to use it.
  package { "nfs-common":
    ensure => installed,
  }
  package { "nfs-kernel-server":
    ensure => installed,
  }
  package { "portmap":
    ensure => installed,
  }
}
