# == Class: undine_drush
#
# The undine_drush class is responsible for the installation of drush in Undine.
# Installation is done via the pear channel at pear.drush.org.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_drush {
  require undine_php

  exec { "/usr/bin/pear channel-discover pear.drush.org":
    unless => '/usr/bin/pear list-channels | grep drush',
    command => '/usr/bin/pear channel-discover pear.drush.org',
  }
  exec { "/usr/bin/pear install drush/drush":
    unless => '/usr/bin/pear list -c pear.drush.org | grep drush | grep \'6.0.0\'',
    command => '/usr/bin/pear install drush/drush-6.0.0',
    require => [
      Exec['/usr/bin/pear channel-discover pear.drush.org'],
    ],
  }
  exec { "/usr/bin/drush":
    command => '/usr/bin/drush',
    require => [
      Exec['/usr/bin/pear install drush/drush'],
    ],
  }
  file { "/home/vagrant/.drush":
    ensure => directory,
    mode => '0700',
    owner => 'vagrant',
    group => 'vagrant',
    require => Exec['/usr/bin/drush'],
  }
}
