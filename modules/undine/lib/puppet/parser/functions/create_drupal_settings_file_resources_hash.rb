# == Function: create_drupal_settings_file_resources_hash
#
# A helper function used by Undine to format a given set of databases, files 
# and settings hashes in undine::drupal_site to be compatible with Puppet's 
# create_resources() function. Most notably, it declares the databases based
# on the configuration passed through the original databases array, and sets
# the variables for public, private and temporary files directories to be 
# consistent with the paths provided in the files array.
#
# === Parameters
#
# [*databases*]
#   The full databases hash provided to undine::drupal_site.
# [*files*]
#   The full files hash provided to undine::drupal_site.
# [*settings*]
#   The full settings hash provided to undine::drupal_site.
#
# === Returns
#
# Returns a hash representing the drupal_settings_file resource to be managed.
#
module Puppet::Parser::Functions
  newfunction(:create_drupal_settings_file_resources_hash, :type => :rvalue) do |args|
    # We're modifying the databases array, but don't want to touch the original,
    # lest it remove important keys. Note that this must be a deep copy.
    databases = Marshal.load(Marshal.dump(args[0]))
    files = args[1]
    settings = args[2]
    settings_path = settings['path']
    resource = {}
    db_filtered = {}

    # Remove the following keys
    undine_db_keys = ['src_ssh_user', 'src_hostname', 'src_ssh_known_host_key', 'src_db_name', 'src_db_user', 'src_db_pass']

    # Take the difference of each database with the key arguments only Undine requires.
    databases.each do |key, db_targets|
      db_filtered[key] = {}
      db_targets.each do |target, db_conn|
        # Intersect keys with those allowable by undine::drupal_db resource.
        db_filtered[key][target] = db_conn.delete_if {|k, v| undine_db_keys.include?(k)}
      end
    end

    # Use initial settings.
    resource[settings_path] = settings

    # Override database settings.
    resource[settings_path]['databases'] = db_filtered

    # Use files array to determine actual files directory paths
    if resource[settings_path]['conf'] == nil
      resource[settings_path]['conf'] = {}
    end
    files.each do |key, value|
      if key == 'private'
        resource[settings_path]['conf']['file_' + key + '_path'] = value['path']
      end
      if key == 'public'
        resource[settings_path]['conf']['file_' + key + '_path'] = value['rel_path']
      end
      if key == 'temporary'
        resource[settings_path]['conf']['file_' + key + '_path'] = value['path']
      end
    end

    return resource
  end
end
