# == Class: undine_git
#
# The undine_git class is responsible for the installation of git in Undine.
# Installation is done via the git-core PPA.
#
# It should not be necessary to declare this class directly, as it will be
# declared automatically by the undine class, which all Undine sites should use.
#
class undine_git {
  undine_apt::ppa { "git-core/ppa":
    ppa_user => 'git-core',
    ppa_name => 'ppa',
    source_list_d_filename => 'git-core-ppa-precise.list',
    source_list_d_source => 'puppet:///modules/undine_git/git-core-ppa-precise.list',
  }

  package { "git":
    ensure => installed,
    require => Undine_apt::Ppa['git-core/ppa'],
  }
}
