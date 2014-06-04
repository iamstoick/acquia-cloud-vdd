# == Function: get_server_filename
#
# A helper function used by Undine to translate a valid ServerName in an httpd
# VirtualHost entry to a filename, with '.' replaced with '-'.
#
# === Parameters
#
# [*server_name*]
#   The ServerName to translate into a filename.
#
# === Returns
#
# A filename to use for the given ServerName, returned as a string.
#
# === Examples
#
# Translates "my.localhost.test" to "my-localhost-test"
#
#   $name = get_project_name('my.localhost.test')
#
module Puppet::Parser::Functions
  newfunction(:get_server_filename, :type => :rvalue) do |args|
    $server_name = args[0]
    return $server_name.gsub(/\./, '-')
  end
end
