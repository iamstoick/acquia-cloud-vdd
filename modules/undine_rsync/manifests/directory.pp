# == Define: directory
#
# The directory defined type is responsible for the management of rsync'd
# directories in Undine. It only supports rsync from local or remote hosts to
# a destination directory on the VM.
#
# It also provides a means of authenticating via SSH using a combination of
# agent forwarding to use your host environment's SSH keys (enabled in Undine
# by default) and manipulating the known_hosts file on the guest VM. To find a 
# given known_hosts entry on your host system, simply use the command 
# `ssh-keygen -H -F example.com` to display the correct key to provide.
#
# === Parameters
#
# [*dest_dir*]
#   The destination directory on the local VM. Defaults to the resource title.
# [*src_dir*]
#   The source directory from which to rsync files. Provide src_hostname to
#   rsync from a remote host.
# [*src_hostname*]
#   Optional. The source hostname from which to rsync files.
# [*src_known_host_key*]
#   Optional. The known_host key of the remote src_hostname provided.
# [*src_username*]
#   Optional. The username to use when authenticating to the remote host.
#
# === Examples
#
# Simple local usage.
# 
# undine_rsync::directory { '/path/to/dest':
#   src_dir => '/path/to/my/src',
# }
# 
# Usage via SSH with a defined remote host and associated known_host entry.
# 
# undine_rsync::directory { '/path/to/dest':
#   src_dir => '/path/to/my/remote/src',
#   src_hostname => 'example.com',
#   src_known_host_key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/DTVaRmJW ...',
#   src_username => 'jsmith',
# }
# 
# 
define undine_rsync::directory (
  $src_dir,
  $dest_dir = $title,
  $src_username = undef,
  $src_hostname = undef,
  $src_known_host_key = undef,
  $logoutput = false,
) {
  include ::undine_rsync

  if $src_username != undef and $src_hostname == undef {
    fail('Remote src_username must accompany src_hostname.')
  }
  if $src_known_host_key != undef and $src_hostname == undef {
    fail('Remote src_hostname must be supplied with src_known_host_key.')
  }
  
  if $src_username != undef {
    $user = "${src_username}@"
  }
  else {
    $user = ''
  }

  if $src_hostname != undef {
    $host = "${src_hostname}:"
  }
  else {
    $host = ''
  }

  $exec_str = "/usr/bin/rsync --timeout=0 -rltgoDvz -e ssh ${user}${host}${src_dir} ${dest_dir}"

  if $src_known_host_key != undef {
    if !defined(Undine_ssh::Known_host["${src_hostname}"]) {
      undine_ssh::known_host { "${src_hostname}":
        key => $src_known_host_key,
      }
    }

    # Declare the relationship with chaining arrows, since we can't rely on
    # changing the initial state of the resource itself if it already exists.
    Undine_ssh::Known_host["${src_hostname}"] -> Exec["${exec_str}"]
  }

  exec { "${exec_str}":
    command => "${exec_str}",
    require => Package['rsync'],
    logoutput => $logoutput,
  }
  exec { "rsync-to-${dest_dir}-ownership":
    command => "/bin/chown -R ${host_uid}:20 ${dest_dir}",
    require => Exec["${exec_str}"],
    logoutput => $logoutput,
  }
  exec { "rsync-to-${dest_dir}-permissions":
    command => "/bin/chmod -R 775 ${dest_dir}",
    require => Exec["rsync-to-${dest_dir}-ownership"],
    logoutput => $logoutput,
  }
}
