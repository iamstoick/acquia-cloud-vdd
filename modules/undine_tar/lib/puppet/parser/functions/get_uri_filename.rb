# == Function: get_uri_filename.rb
#
# A helper function used by Undine to retrieve the filename of a given valid
# absolute URI.
#
# === Parameters
#
# [*uri_string*]
#   The URI string to retrieve the filename of.
#
# === Returns
#
# The associated filename for the given URI (the component of the URI after
# the last forward slash).
#
# === Examples
#
# Returns my_archive.tar.gz
#
# $is_curl_uri = is_absolute_uri('http://my.localhost.test/my_archive.tar.gz')
#
require 'uri'

module Puppet::Parser::Functions
  newfunction(:get_uri_filename, :type => :rvalue) do |args|
    uri_string = args[0]
    u = URI::parse(uri_string)
    return File.basename(u.path)
  end
end
