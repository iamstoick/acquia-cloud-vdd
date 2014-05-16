# == Class: undine_vim
#
# The undine_vim class is responsible for the installation of vim in Undine.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_vim {
  package { 'vim':
    ensure => installed,
  }
}
