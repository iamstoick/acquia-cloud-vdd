# == Define: known_host
#
# The known_host defined type is responsible for the management of entries in
# the known_host file in Undine, used by the root user during provisioning (via
# sudo).
#
# Undine provides a means of authenticating via SSH using a combination of agent
# forwarding to use your host environment's SSH keys without copying them into
# the guest VM (enabled in Undine by default) and manipulating the known_hosts 
# file on the guest VM to facilitate host authentication. To find a known_hosts
# entry on your host system, simply use `ssh-keygen -H -F git.example.com` to 
# display the corresponding key for a given hostname.
#
# === Parameters
#
# [*key*]
#   The key of the repository to add to known_hosts for use with SSH.
# [*hostname*]
#   Optional. The hostname of the repository to whitelist when using SSH.
#   Defaults to the resource title.
#
# === Examples
#
# Create a known_host entry for git.example.com
#
#   undine_ssh::known_host { 'git.example.com':
#     key => '|1|nddsvUkIUHNdM31TTSc+sPT57yg=|nQqEyJJthk/DTVaRmJWtxGRVCis= ...'
#   }
#
define undine_ssh::known_host (
  $hostname = $title,
  $key,
) {
  include ::undine_ssh

  exec { "add-known-host-${hostname}":
    unless => "/usr/bin/ssh-keygen -H -F ${hostname} | /bin/grep found",
    command => "/bin/echo \"${key}\" >> /root/.ssh/known_hosts",
    require => [
      File['/root/.ssh'],
      Package['openssh-client'],
    ],
  }
}
