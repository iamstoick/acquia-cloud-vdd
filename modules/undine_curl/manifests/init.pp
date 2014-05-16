# == Class: undine_curl
#
# The undine_culr class is responsible for the installation of curl in Undine.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_curl {
  package { 'curl':
    ensure => installed,
  }
}
