# == Define: ppa
#
# The ppa resource represents a single signed Personal Package Archive (PPA)
# to be managed via apt-add-repository. Optionally, users may choose to manage
# the associated source list files stored in source.list.d by supplying the
# filename and source content.
#
# === Parameters
#
# [*ppa_user*]
#   The name of the user from which the PPA is being retrieved.
# [*ppa_name*]
#   The name of the PPA to retrieve from the user defined in ppa_user.
# [*source_list_d_content*]
#   Optional. The raw content to use for the source.list.d file, as a string.
#   Mutually exclusive with source_list_d_source.
# [*source_list_d_source*]
#   A source file, which will be copied into place on the local system within
#   source.list.d, with the same usage as the file resource. Mutually exclusive
#   with source_list_d_content.
# [*source_list_d_filename*]
#   Optional. The filename of the associated source.list.d file to manage.
#   Required when source_list_d_content or source_list_d_source is set.
#
# === Examples
#
# To use packages from a PPA, first declare the PPA, then require the PPA
# resource from the package resource you want to declare.
#
# undine_apt::ppa { 'git-core/git':
#   ppa_user => 'git-core',
#   ppa_name => 'git',
#   source_list_d_filename => 'git-core-ppa-precise.list'
#   source_list_d_source => 'puppet:///modules/my_git_module/git-core-ppa-precise.list',
# }
#
# package { 'git':
#   require Undine_apt::Ppa['git-core/git'],
#   ensure => installed,
# }
#
define undine_apt::ppa (
  $ppa_user,
  $ppa_name,
  $source_list_d_filename = undef,
  $source_list_d_source = undef,
  $source_list_d_content = undef,
) {
  include ::undine_apt

  if $source_list_d_content and $source_list_d_source {
    fail('You may not supply both content and source parameters to an PPA source.list.d file.')
  }
  elsif $source_list_d_content == undef and $source_list_d_source == undef and $source_list_d_filename != undef {
    fail('You must supply either content or a source to an PPA source.list.d file if a filename is provided.')
  }
  elsif ($source_list_d_content != undef or $source_list_d_source != undef) and $source_list_d_filename == undef {
    fail('You must supply a filename for the source.list.d file if either the file\'s contents or a source is provided.')
  }

  exec { "apt-update-ppa-${ppa_user}-${ppa_name}":
    command => '/usr/bin/apt-get update',
  }

  exec { "add-ppa-${ppa_user}-${ppa_name}":
    command => "/usr/bin/add-apt-repository ppa:${ppa_user}/${ppa_name}",
    unless => "/bin/grep \"${ppa_user}/${ppa_name}\" /etc/apt/sources.list /etc/apt/sources.list.d/*",
    require => Package['python-software-properties'],
    notify => Exec["apt-update-ppa-${ppa_user}-${ppa_name}"],
  }

  file { "/etc/apt/sources.list.d/${source_list_d_filename}":
    ensure => file,
    source => $source_list_source,
    content => $source_list_content,
    require => Exec["add-ppa-${ppa_user}-${ppa_name}"],
    notify => Exec["apt-update-ppa-${ppa_user}-${ppa_name}"],
  }
}
