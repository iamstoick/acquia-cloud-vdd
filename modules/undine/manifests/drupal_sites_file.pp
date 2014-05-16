# == Define: drupal_sites_file
#
# The drupal_sites_file resource represents an individual sites.php file (or 
# potentially, an include for another settings.php file in the same format)
# for use with Drupal 7.
#
# === Parameters
#
# [*path*]
#   The path to the file to manage. Defaults to the resource label.
# [*sites*]
#   A hash mapping hostnames, ports, and pathnames to configuration directories
#   in the Drupal sites directory. URL mappings (keys in the hash) are in the 
#   format '<port>.<domain>.<path.to.site>', while the corresponding directory
#   values are relative to the sites directory of the Drupal install.
#		
# === Examples
#
# Maps http://localhost:8080/example/foo to the example subdirectory of sites.
#
# undine::drupal_sites_file { '/var/www/mysite/sites/sites.php':
#   sites => {
#     '8080.localhost.example' => 'example',
#   }
# }
#
define undine::drupal_sites_file (
  $path = $title,
  $sites,
) {
  include ::undine

  file { "$path":
    ensure => file,
    content => template('undine/drupal_sites_file.erb'),
  }
}
