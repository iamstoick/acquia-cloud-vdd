# == Function: get_project_name
#
# A helper function used by Undine to extract only the final subdirectory of a
# given directory where Drupal should reside.
#
# This is used by the defined type undine::drupal_codebase when creating a site
# from a given core version instead of a Git repository, as drush dl splits the
# full directory of the site into two arguments: the parent directory of the
# site, and the name of its subdirectory that will actually contain the site.
#
# To retrieve only the former, use get_project_basepath instead.
#
# === Parameters
#
# [*directory*]
#   The full project source directory string to parse.
#
# === Returns
#
# Returns the final subdirectory of the path provided as a string.
#
# === Examples
#
# Both examples assign 'mysite' to $name.
#
#   $name = get_project_name('/var/www/html/mysite')
#   $name = get_project_name('/var/www/html/mysite/')
#
module Puppet::Parser::Functions
  newfunction(:get_project_name, :type => :rvalue) do |args|
    return File.basename(args[0])
  end
end
