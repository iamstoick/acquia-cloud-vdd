# == Function: is_absolute_uri
#
# A helper function used by Undine to confirm whether a given URI is a valid
# absolute URI.
#
# === Parameters
#
# [*uri_string*]
#   The URI string to determine the validity of.
#
# === Returns
#
# True if the string is a valid absolute URI, false otherwise.
#
# === Examples
#
# Tests whether http://my.localhost.test is a valid absolute URI.
#
# $is_curl_uri = is_absolute_uri('http://my.localhost.test')
#
require 'uri'

module Puppet::Parser::Functions
  newfunction(:is_absolute_uri, :type => :rvalue) do |args|
    uri_string = args[0]
    if uri_string =~ URI::ABS_URI
      return true
    end
    return false
  end
end
