# == Define: drupal_files_dir
#
# The drupal_files_dir resource represents an individual files directory for 
# for use with Drupal 7. It may optionally specify a source from which to
# retreive its contents.
#
# Although it is possible to use directly, it is primarly used by the 
# undine::drupal_site defined type to populate files directories from multiple
# potential sources, as Puppet 2.7 does not support iterating over collections.
#
# === Parameters
#
# [*path*]
#   The path to the directory to manage. Defaults to the resource label.
# [*src_type*]
#   Optional. The type of source to read from. Must be one of 'rsync' or 'tar'.
# [*src_details*]
#   Optional. The details of the source to read from represented as a hash, sans
#   destiation path. This should be a key-quoted hash representation of an
#   undine_tar::archive resource if src_type is 'tar', or an 
#   undine_rsync::directory resource if 'rsync' is used. Required if src_type is
#   set.
#		
# === Examples
#
# Retrieves a tar archive to the named directory.
#
#   undine::drupal_files_dir { '/var/www/mysite/sites/default/files':
#     src_type => 'tar',
#     src_details => {
#       'src_path' => 'http://example.com/path/to/my/archive.tar.gz',
#       'src_username' => 'jsmith',
#       'src_password' => 'correcthorsebatterystaple',
#       'gzip' => true,
#     },
#   }
#
# Retrieves content for the named directory via rsync.
#
#   undine::drupal_files_dir { '/var/www/mysite/sites/default/files':
#     src_type => 'rsync',
#     src_details => {
#       'src_path' => '/path/to/my/remote/src',
#       'src_hostname' => 'example.com',
#       'src_known_host_key' => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/ ...',
#       'src_username' => 'jsmith',
#     },
#   }
#

define undine::drupal_files_dir (
  $path = $title,
  $src_type = undef,
  $src_details = undef,
) {
  include ::undine

  file { "$path":
    ensure => directory,
    mode => '0775',
    recurse => true,
  }

  $defaults = {
    'require' => "File[${path}]",
  }

  if $src_type == 'tar' {
    $tar_src = { "$path" => $src_details }
    create_resources(undine_tar::archive, $tar_src, $defaults)
  }
  elsif $src_type == 'rsync' {
    $rsync_src = { "$path" => $src_details }
    create_resources(undine_rsync::directory, $rsync_src, $defaults)
  }
}
