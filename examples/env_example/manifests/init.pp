# == Environment Example: ./examples/env_example/manifests/init.pp
#
# Advanced users may further customize their Undine environment by declaring
# additional resources, usually provided by Undine's resource types. While any
# configuration specific to a given Drupal site (or multisite instance) belongs
# in ./sites, environment-specific configuration can be specified through a
# very similar means in ./env, keeping the two organized and separate.
#
# The following configuration uses the files in the ../files directory to set 
# the PHP memory_limit to 256M (up from Undine's default of 128M), and the MySQL
# max_allowed_packet to 32M (up from Undine's default of 16M).
#
# To use this as the basis of your configuration, copy the env_example directory
# into ./env, and add the following line to ./manifests/site.pp
#
#   include env_example
#
# The next time you run either "vagrant up" (if you haven't run it yet) or
# "vagrant provision" (if you have), your changes will be reflected.
#
class env_example {
  # Override configuration to set max_allowed_packet.
  undine_percona::misc_conf_file { '/etc/mysql/conf.d/override.cnf':
    source => 'puppet:///modules/env_example/override.cnf',
  }
  # Override the PHP memory_limit. Note the dependency on the mod_php package.
  undine_apache::misc_conf_file { '/etc/php53/apache2/conf.d/limits.ini':
    source => 'puppet:///modules/env_example/limits.ini',
    require => Package['libapache2-mod-php53'],
  }

  # undine_git::identity provides an easy means of setting your Git identity
  # during setup. Change this to your own identity.
  # 
  # undine_git::identity { 'Jane Smith':
  #   email => 'jsmith@example.com',
  # }
}
