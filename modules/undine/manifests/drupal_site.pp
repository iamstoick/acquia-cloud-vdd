# == Define: drupal_site
#
# NOTE: This is only a skeleton and spec for the full implementation to follow.
#
# The drupal_site resource represents an individual Drupal 7 site that resides
# within a given codebase. 
#
# At minimum, it declares one or more databases that may be used with the site.
# The user may also declare a settings.php file path (or include with the same
# syntax) where the database configuration and other settings will be written.
# Additionally, files directories may be declared, with their contents
# optionally retrieved via rsync from a remote source.
#
# === Parameters
#
# [*path*]
#   The path to the Drupal site. Defaults to the resource label.
# [*databases*]
#   A hash of database connections. The keys correspond to Drupal connection
#   keys,  a unique identifier for a given database connection as defined in 
#   https://drupal.org/node/310071. At least one of these keys must be named 
#   "default." Each value corresponds to a hash of one or more targets 
#   (alternate databases to be used if available). 
#
#   Each target is itself a hash, with the key corresponding to the target's
#   unique identifier. As with connection keys, there must be at least one
#   target key named "default." The value of each target is a series of 
#   key-value pairs defining the connection information, as one would in 
#   settings.php.
#
#   Each target has a number of optional special keys, used by Undine to both 
#   create the database (if the driver used is MySQL) and import the database
#   contents from an external source.
#
#   [*driver*]
#     The database driver to use. Must be 'mysql' to automatically create and/or
#     import the database and database user.
#   [*database*]
#     The name of the database. Will be created if using the mysql driver.
#   [*username*]
#     The name of the database user. Will be created if using the mysql driver.
#   [*password*]
#     The password for the database user.
#   [*host*]
#     Optional. The host of the database to connect to. Defaults to localhost.
#   [*prefix*]
#     Optional. The prefix to use for database tables.
#   [*charset*]
#     Optional. The character set to use.
#   [*collation*]
#     Optional. The default database collation to use.
#   [*src_path*]
#     Optional. The local source path of a SQL database dump to import. Mutually
#     exclusive with the src_ssh parameters.
#   [*src_ssh_user*]
#     Optional. The remote ssh user to use when connecting to the source 
#     database.
#   [*src_ssh_host*]
#     Optional. The host on which the remote database resides. Must be supplied
#     when retrieving a database from a remote host via SSH.
#   [*src_ssh_known_host_key*]
#     Optional. The known_host key of the remote host to connect to when
#     retrieving a database from a remote host via SSH.
#   [*src_db_name*]
#     Optional. The remote database to connect to when retrieving a database 
#     dump. Must be supplied when retrieving a database from a remote host via
#     SSH.
#   [*src_db_user*]
#     Optional. The database user to use when connecting to the remote database.
#     Must be supplied when retrieving a database from a remote host via SSH.
#   [*src_db_pass*]
#     Optional. The password to use when connecting to the remote database.
#   [*su_user*]
#     Optional. The database superuser name to use when creating the database.
#     Defaults to root.
#   [*su_pass*]
#     Optional. The database superuser password to use when creating the 
#     database. No password is set by default.
# [*files*]
#     Optional. A hash with up to three keys (public, private and temporary),
#     each representing one of Drupal's files directories. The value for each is
#     a hash providing additional configuration information, with keys and
#     values as follows:
#
#     [*path*]
#       The path of the files directory. If set, this path will also be defined
#       in the settings file defined below for private files. Public files
#       define their path in rel_path instead.
#     [*rel_path*]
#       The site-relative path of the files directory (such as
#       sites/default/files) to be used in settings.php. Only used for public
#       files.
#     [*src_type*]
#       Optional. Defines the type of source to populate the files directory 
#       with. 'tar' and 'rsync' are currently supported.
#     [*src_details*]
#       Optional. A hash with the same keys and values as the resource type
#       defined in src_type (either undine_tar::archive or 
#       undine_rsync::directory, respectively), with the path key omitted. See
#       the documentation for each source type for details. Required when the
#       src_type parameter is set.
# [*settings*]
#     Optional. A hash representing the accompanying settings.php file (or like-
#     formatted include file) for this site. If set, the file will include the
#     database information supplied in databases above as well as the paths used
#     for private and public files, so it is not necessary to repeat either 
#     here. The keys and values of this hash are as follows:
#
#     [*path*]
#       The full path to the settings file to manage. If this is the only key
#       defined, it will only write a settings file with the connection details
#       defined in databases above, as well as the paths supplied for private
#       and public files.
#     [*update_free_access*]
#       Optional. A boolean dictating whether update.php should be freely
#       accessible to all visitors. Defaults to FALSE.
#     [*hash_salt*]
#       Optional. The salt used to hash passwords.
#     [*cookie_domain*]
#       Optional. The domain to use for session cookies, starting with a 
#       leading dot (per RFC 2109).
#     [*base_url*]
#       Optional. The absolute URL for your Drupal installation, without a 
#       trailing slash.
#     [*conf*]
#       Optional. A hash containing key-value pairs for default values that
#       should exist in the variables table.
#     [*unset*]
#       Optional. An array of PHP variables to unset before any other
#       configuration is written. Most commonly used in conditionally included
#       files.
#		
# === Examples
#
# Typical configuration for a single-site install. This creates a database
# called 'my_db' with the user 'db_user' and retrieves the contents from
# 'remote_src_db' at 'ssh.example.com' to populate it. It continues to ensure
# the files directory is created and properly permissioned, with content sourced
# in via rsync on the same remote host. Finally, the settings.php file is 
# generated with the the necessary database and public files configuration.
#
# undine::drupal_site { '/var/www/sites/default':
#   databases => {
#     'default' => {
#       'default' => {
#         'driver' => 'mysql',
#         'database' => 'my_db',
#         'username' => 'db_user',
#         'password' => 'correcthorsebatterystaple',
#         'src_ssh_user' => 'ssh_user',
#         'src_ssh_host' => 'ssh.example.com',
#         'src_ssh_known_host_key' => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQq ...',
#         'src_db_name' => 'remote_src_db',
#         'src_db_user' => 'remote_mysql_user',
#         'src_db_pass' => 'correcthorsebatterystaple',
#       },
#     },
#   },
#   files => {
#     'public' => {
#       'path' => '/var/www/sites/default/files',
#       'rel_path' => 'sites/default/files',
#       'src_type' => 'rsync',
#       'src_details' => {
#         'src_dir' => '/var/www/path/to/my/files',
#         'src_username' => 'ssh_user',
#         'src_hostname' => 'ssh.example.com',
#         'src_known_host_key' => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQq ...',
#       },
#     },
#   },
#   settings => {
#     path => '/var/www/sites/default/settings.php',
#   },
# }
#

define undine::drupal_site (
  $path = $title,
  $databases,
  $settings = undef,
  $files = undef,
) {
  # Declare default values for drupal_db resources.
  $databases_defaults = {
    'driver' => 'mysql',
    'su_user' => 'root',
    'su_pass' => undef,
    'src_ssh_user' => undef,
    'src_ssh_host' => undef,
    'src_ssh_known_host_key' => undef,
    'src_db_name' => undef,
    'src_db_user' => undef,
    'src_db_pass' => undef,
  }

  # Create drupal_db resources.
  $databases_hash = create_drupal_db_resources_hash($databases, $path)
  create_resources(undine::drupal_db, $databases_hash, $databases_defaults)

  # Create drupal_files_dir resources.
  $files_hash = create_drupal_files_dir_resources_hash($files)
  create_resources(undine::drupal_files_dir, $files_hash)

  # Create drupal_settings_file resources.
  $settings_hash = create_drupal_settings_file_resources_hash($databases, $files, $settings)
  create_resources(undine::drupal_settings_file, $settings_hash)
}
