# == Class: undine_sendmail
#
# The undine_sendmail class is responsible for the installation of the sendmail
# package in Undine.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_sendmail {
  package { 'sendmail':
    ensure => installed,
  }
}
