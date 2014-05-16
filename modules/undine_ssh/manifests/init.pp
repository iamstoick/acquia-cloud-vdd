# == Class: undine_ssh
#
# The undine_ssh class is responsible for the installation of the openssh-client
# package, necessary for the management of SSH known_host keys.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by declaring a undine_ssh::known_host resource.
#
class undine_ssh { 
  package { "openssh-client":
    ensure => installed,
  }

  file { "/root/.ssh":
    ensure => directory,
    mode => '0640',
  }
}
