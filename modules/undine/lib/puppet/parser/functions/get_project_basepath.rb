# == Function: get_project_basepath
#
# A helper function used by Undine to extract only the path before the final
# subdirectory of a given directory where Drupal should reside.
#
# This is used by the defined type undine::drupal_codebase when creating a site 
# from a given core version instead of a Git repository, as drush dl splits the
# full directory of the site into two arguments: the parent directory of the
# site, and the name of its subdirectory that will actually contain the site.
#
# To retrieve only the later, use get_project_name instead.
#
# === Parameters
#
# [*directory*]
#   The full project source directory string to parse.
#
# === Returns
#
# Returns the path prior to the final subdirectory of the path provided as a
# string.
#
# === Examples
#
# Both examples assign '/var/www/html' to $basepath.
#
# $basepath = get_project_basepath('/var/www/html/mysite')
# $basepath = get_project_basepath('/var/www/html/mysite/')
#
module Puppet::Parser::Functions
  newfunction(:get_project_basepath, :type => :rvalue) do |args|
    return File.dirname(args[0])
  end
end
