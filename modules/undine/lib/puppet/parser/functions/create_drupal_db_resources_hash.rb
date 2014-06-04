# == Function: create_drupal_db_resources_hash
#
# A helper function used by Undine to format a given $databases array in
# undine::drupal_site to be compatible with Puppet's create_resources() 
# function.
#
# === Parameters
#
# [*databases*]
#   The full databases hash provided to undine::drupal_site.
# [*site_name*]
#   The name of the undine::drupal_site resource. This is used to distinguish
#   database keys of the same name across different sites.
#
# === Returns
#
# Returns a hash representing the drupal_db resources to be managed.
#
module Puppet::Parser::Functions
  newfunction(:create_drupal_db_resources_hash, :type => :rvalue) do |args|
    # We're modifying the databases array, but don't want to touch the original,
    # lest it remove important keys. Note that this must be a deep copy.
    db_conn_keys = Marshal.load(Marshal.dump(args[0]))
    site_name = args[1]
    resources = {}

    valid_keys = ['driver', 'database', 'username', 'password', 'su_user', 'su_pass', 'src_ssh_user', 'src_hostname', 'src_ssh_known_host_key', 'src_db_name', 'src_db_user', 'src_db_pass']

    # Intersect each database with the key arguments drupal_db requires.
    db_conn_keys.each do |key, db_targets|
      db_targets.each do |target, db_conn|
        # Intersect keys with those allowable by undine::drupal_db resource.
        resources[target + "_" + site_name] = db_conn.delete_if {|k, v| !valid_keys.include?(k)} 
      end
    end
    
    return resources
  end
end
