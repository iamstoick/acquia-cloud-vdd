# == Class: undine_tar
#
# The undine_tar class is responsible for the installation of tar in Undine.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_tar {
  package { 'tar':
    ensure => installed,
  }
}
