# == Define: archive
#
# The archive defined type is responsible for the retrieval and extraction of 
# tar archives in Undine. It supports retrieval from the local environment or
# remote hosts (via wget) to a destination directory on the VM, where it is
# optionally extracted (as if using tar -xzf <tarball>).
#
# When retrieving archives via wget, support is also included for basic auth.
#
# === Parameters
#
# [*path*]
#   The destination directory on the local VM. 	Defaults to the resource title.
# [*src_path*]
#   The source path from which to retrieve files. Can either be a local
#   directory or an absolute URI compatible with wget.
# [*src_username*]
#   Optional. The username to use when authenticating to the remote host using
#   basic auth.
# [*src_password*]
#   Optional. The password to use when authenticating to the remote host using
#   basic auth.
# [*gzip*]
#   Optional. Whether to use gzip decompression for the source archive. Defaults
#   to FALSE.
#
# === Examples
#
# Simple local usage.
# 
#   undine_tar::archive { '/path/to/dest':
#     src_path => '/path/to/my/src/archive.tar',
#   }
# 
# Usage via wget via basic auth, with gzip support.
# 
#   undine_tar::archive { '/path/to/dest':
#     src_path => 'http://example.com/path/to/my/archive.tar.gz',
#     src_username => 'jsmith',
#     src_password => 'correcthorsebatterystaple',
#     gzip => true,
#   }
#
define undine_tar::archive (
  $path = $title,
  $src_path,
  $src_username = undef,
  $src_password = undef,
  $gzip = false,
) {
  include ::undine_tar

  file { "${path}":
    ensure => 'directory',
    recurse => true,
    before => Exec["Extract archive ${title}"],
  }

  $use_wget = is_absolute_uri($src_path)

  # Retrieve the archive via wget first (and modify the local path) if needed.
  if $use_wget == true {
    if ($src_username == undef) != ($src_password == undef) {
      fail('Username and password must both be set or unset when retrieving a tar archive via cURL.')
    }

    if ($src_username != undef) {
      $userflag = "--http-user='${src_username}'"
    }
    else {
      $userflag = ''
    }
    if ($src_password != undef) {
      $passflag = "--http-password='${src_password}'"
    }
    else {
      $passflag = ''
    }

    $filename = get_uri_filename($src_path)
    $local_path = "/tmp/${filename}"

    exec { "/usr/bin/wget ${userflag} ${passflag} -P /tmp ${src_path}":
      before => Exec["Extract archive ${title}"],
    }
  }
  else {
    $local_path = $path
  }

  if $gzip == true {
    $gzip_flag = 'z'
  }
  else {
    $gzip_flag = ''
  }

  exec { "Extract archive ${title}":
    command => "/bin/tar -xv${gzip_flag}f ${local_path} -C ${path}",
  }
}
