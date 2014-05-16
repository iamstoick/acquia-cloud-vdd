# == Define: drupal_settings_file
#
# The drupal_settings_file resource represents an individual settings.php file
# (or potentially, an include for another settings.php file in the same format)
# for use with Drupal 7.
#
# === Parameters
#
# [*path*]
#   The path to the file to manage. Defaults to the resource label.
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
# [*update_free_access*]
#   Optional. A boolean dictating whether update.php should be freely accessible to all
#   visitors. Defaults to FALSE.
# [*hash_salt*]
#   Optional. The salt used to hash passwords.
# [*cookie_domain*]
#   Optional. The domain to use for session cookies, starting with a leading dot
#   (per RFC 2109).
# [*base_url*]
#   Optional. The absolute URL for your Drupal installation, without a trailing
#   slash.
# [*conf*]
#   Optional. A hash containing key-value pairs for default values that should
#   exist in the variables table.
# [*unset*]
#   Optional. An array of PHP variables to unset before any other configuration
#   is written. Most commonly used in conditionally included files.
#		
# === Examples
#
# undine::drupal_settings_file { '/var/www/mysite/sites/default/settings.php':
#   unset => [
#     "$conf['my_var']",
#     "$conf['my_other_var']",
#   ],
#   databases => {
#     'default' => {
#       'default' => {
#         'driver' => 'mysql',
#         'database' => 'my_db',
#         'username' => 'db_user',
#         'password' => 'correcthorsebatterystaple',
#         'host' => 'localhost',
#         'prefix' => 'mysite_',
#         'collation' => 'utf8_general_ci',
#       },
#     },
#   },
#   update_free_access => false,
#   hash_salt => 'p3pp3r',
#   cookie_domain => '.example.com',
#   base_url => 'http://example.com/mysite',
#   conf => {
#     'some_other_var' => '1',
#   }
# }
#
define undine::drupal_settings_file (
  $path = $title,
  $databases,
  $update_free_access = undef,
  $cookie_domain = undef,
  $hash_salt = undef,
  $base_url = undef,
  $conf = undef,
  $unset = undef,
) {
  include ::undine

  file { "$path":
    ensure => file,
    content => template('undine/drupal_settings_file.erb'),
  }
}
