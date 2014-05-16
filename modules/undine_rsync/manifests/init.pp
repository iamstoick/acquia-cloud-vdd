# == Class: undine_rsync
#
# The undine_rsync class is responsible for the installation of rsync in Undine.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_rsync {
  package { 'rsync':
    ensure => installed,
  }
}
