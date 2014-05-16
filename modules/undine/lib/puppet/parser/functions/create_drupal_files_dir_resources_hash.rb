# == Function: create_drupal_files_dir_resources_hash
#
# A helper function used by Undine to format a given $files array in
# undine::drupal_site to be compatible with Puppet's create_resources() 
# function. Most notably, it replaces the labels "public" and "private"
# with the paths of the resources to manage.
#
# === Parameters
#
# [*files*]
#   The full files hash provided to undine::drupal_site.
#
# === Returns
#
# Returns a hash representing the drupal_files_dir resources to be managed.
#
module Puppet::Parser::Functions
  newfunction(:create_drupal_files_dir_resources_hash, :type => :rvalue) do |args|
    files = args[0]
    resources = {}

    # Re-label resource keys with path information to avoid collisions.
    files.each do |key, value|
      # Deep copy the value to avoid any weirdness when we strip keys.
      path = value['path']
      resources[path] = Marshal.load(Marshal.dump(value))
    end

    valid_keys = ['path', 'src_type', 'src_details']

    resources.each do |key, value|
      # Intersect keys with those allowable by undine::drupal_files_dir.
      resources[key] = value.delete_if {|k, v| !valid_keys.include?(k) }
    end

    return resources
  end
end
