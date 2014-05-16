# == Function: convert_grants_to_resources
#
# A helper function used by Undine to convert a hash of arrays in database =>
# permissions format to a hash of hashes to be converted to exec resources for a
# given username.
#
# === Parameters
#
# [*username*]
#   The username to GRANT permissions to.
# [*grants*]
#   A hash of arrays, keyed by database names and containing an array of MySQL 
#   privileges to GRANT via an exec resource later.
# [*su_user*]
#   The super user that will GRANT the privileges.
# [*su_pass*]
#   The password for the super user that will GRANT the privileges.
#
# === Returns
#
# Returns a hash of hashes compatible with create_resources(exec, ...)
# representing the permissions granted to username for each database named in
# grants.
#
# === Examples
#
# GRANTs the CREATE, UPDATE, and DELETE permissions on my_database to my_user.
#
# $grants = {
#   'my_database' => [
#     'CREATE',
#     'UPDATE',
#     'DELETE',
#   ],
# }
# $exec_hash = convert_grants_to_resources('my_user', $grants)
# create_resources(exec, $exec_hash)
#
module Puppet::Parser::Functions
  newfunction(:convert_grants_to_resources, :type => :rvalue) do |args|
    username = args[0]
    grants = args[1]
    su_user = args[2]
    if defined? args[3]
      su_pass_flag = "-p#{args[3]}"
    else
      su_pass_flag = ''
    end 

    exec = Hash.new()
    grants.each do |database, permissions_arr|
      permissions = permissions_arr.join(', ')
      # Namevar used instead of command attribute as workaround to
      # projects.puppetlabs.com/issues/21409: create_resources ignore exec
      # type's command attribute.
      exec["/usr/bin/mysql -u#{su_user} #{su_pass_flag} -e 'GRANT #{permissions} ON #{database}.* TO '#{username}'@'localhost'; FLUSH PRIVILEGES'"] = {
        'unless' => "/usr/bin/mysql -u#{su_user} #{su_pass_flag} -e \"SHOW GRANTS FOR '#{username}'@'localhost'\" | grep '#{permissions}'",
      }
    end
    return exec
  end
end
