# == Sites Example: ./examples/sites_example/manifests/init.pp
# 
# Drupal sites are configured by declaring an undine::drupal_codebase
# resource, followed by any number of undine::drupal_site resources that
# require it. This allows for configuration of both single and multisite 
# installations of Drupal.
#
# To use this as the basis for your Drupal site, first locate the "sites"
# directory of your Undine install, then copy the ./examples/site_example
# directory into it.
#
# Finally, add the line "include sites_example" to the file 
# /path/to/undine/manifests/site.pp to tell Undine to configure your site.
#
# The next time you run either "vagrant up" (if you haven't run it yet) or 
# "vagrant provision" (if you have), your changes will be reflected.
#
class sites_example {
  # Require the undine package to ensure dependencies are met.
  require undine

  # Drupal sites are configured by declaring an undine::drupal_codebase
  # resource, followed by any number of undine::drupal_site resources that
  # require it. This allows for configuration of both single and multisite 
  # installations of Drupal.
  #
  # Anything requiring the codebase must explicitly say so using the following
  # resource key (note the capitalization):
  #
  # require => Undine::Drupal_codebase['/var/www/mysite'],
  #
  undine::drupal_codebase { '/var/www/mysite':
    git_source => "ssh://git@example.com/mysite.git",
    branch => 'master',
    known_host_name => 'example.com',
    known_host_key => '|1|afy2983hyBaodisf09hXdasoigh1rfdDF...'
  }

  # This creates a Drupal site within the codebase, including database setup,
  # files directory configuration, and settings.php configuration. Note that
  # you could write to settings.local.inc (or any other filename) if your 
  # settings.php is revisioned and set to include other files for local config.
  # Also note that "default" is simply a special case for single-site installs.
  #
  # The 'require' key is necessary to ensure the codebase is in place before
  # configuring the site. Again, note the change in capitalization.
  #
  undine::drupal_site { '/var/www/mysite/sites/default':
    databases => {
      'default' => {
        'default' => {
          'driver' => 'mysql',
          'host' => 'localhost',
          'database' => 'mysite',
          'username' => 'mysite_user',
          'password' => 'correcthorsebatterystaple',
        },
      },
    },
    files => {
      'public' => {
        'path' => '/var/www/mysite/sites/default/files',
        'rel_path' => 'sites/default/files',
      },
      'private' => {
        'path' => '/path/to/private-files',
      },
    },
    settings => {
      'path' => '/var/www/mysite/sites/default/settings.php',
    },
    require => Undine::Drupal_codebase['/var/www/mysite'],
  }

  # This creates a managed sites.php file, to ensure proper mapping of
  # settings.php for each site. Note that this assumes use of corresponding
  # virtual hosts (see below). Unnecessary for single-site installs.
  #
  # Note that undine::drupal_sites_file may be named anything (such as
  # sites.local.inc, for example), in the event your sites.php is revisioned
  # and set to include another file for local development.
  #
  # undine::drupal_sites_file { '/var/www/mysite/sites/sites.php':
  #   sites => {
  #     '8080.mysite.local' => 'mysite',
  #     '8443.mysite.local' => 'mysite',
  #   }
  # }

  # This adds the necessary Apache configuration for the virutal host named
  # 'mysite.local'. Note that Undine is accessed via Port 8080 and Port 8443
  # in your browser by default.
  #
  # Add the following entry to your hosts file to use the virtual host:
  #
  # 127.0.0.1    mysite.local
  #
  undine_apache::virtualhost { 'mysite.local':
    document_root => '/var/www/mysite',
    require => Undine::Drupal_codebase['/var/www/mysite'],
  }
}
