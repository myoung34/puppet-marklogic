# == class Marklogic::activator
#
# This class handles the activation of MarkLogic
#
# === Requires
#  [*puppetlabs-stdlib*](https://github.com/puppetlabs/puppetlabs-stdlib)
#  [*puppetlabs-firewall*](https://github.com/puppetlabs/puppetlabs-firewall)
#
# === Parameters
#
# [*admin_password*]
#   The default user password to create for HTTP authentication
#     *default*: admin
# [*admin_user*]
#   The default username to create for HTTP authentication
#     *default*: admin
# [*is_upgrade*]
#   Boolean to determine if the marklogic is in upgrade state. If it is, then the activation
#     needs to hit a special step to upgrade the current databases before continuing the
#     activation process. Default is false.
# [*licensee*]
#   The *licensee* information for the MarkLogic license information
# [*license_key*]
#   The *license key* information for the MarkLogic license information
# [*version*]
#   The version of MarkLogic to look for. MarkLogic will resemble *MarkLogic-{version}.x86_64.rpm*.
#
# === Examples
#
# Provide some examples on how to use this type:
#
#   class { 'marklogic::activator':
#     admin_password  => 'legit1!',
#     admin_user      => 'admin',
#     is_upgrade      => false,
#     licensee        => 'My Company',
#     license_key     => '####-####-####-####-####',
#     version         => '6.0-4',
#   }
#
# === Authors
#
# Marcus Young <myoung34@my.apsu.edu>
#
class marklogic::activator (
  $admin_password,
  $admin_user,
  $is_development_license,
  $is_upgrade,
  $licensee,
  $license_key,
  $version,
) {
  package { 'wget':
    ensure => installed,
  }

  service { 'MarkLogic':
    ensure => 'running',
    enable => true,
  }

  $http_auth = "--user=${admin_user} --password=${admin_password} "
  $server_url = 'http://localhost:8001'
  # TODO: Generate a true SSL key and allow cluster joining
  $ssl = 'YXNkZgo=' #This is a required parameter to the 'join cluster' URL, but not needed, and has to be a valid base64 string
  $wget = '/usr/bin/wget --quiet -O - '

  if $is_development_license {
    $license_type = 'development'
  } else {
    $license_type = 'evaluation'
  }

  # The only difference between activation on versions of MarkLogic at this
  # time is the order of execution steps, and which executions are made. To
  # improve readability, each Exec is disabled by default and has an 'on'
  # switch, or boolean tied to it. This allows you to choose which Exec must
  # happen, and chain the order.
  $accept_cmd = "${wget} ${http_auth} \"${server_url}/agree-go.xqy?accepted-agreement=${license_type}&ok.x=32&ok.y=17&ok=accept\" > /dev/null"
  $initialize_cmd = "${wget} ${http_auth} \"${server_url}/initialize-go.xqy\" > /dev/null 2>&1"
  $join_cmd = "${wget} \"${server_url}/join-admin-go.xqy?new-server=${::fqdn}&new-server-port=8001&bind=7999&connect=7999&server=&port=8001&cancel=cancel&ssl-certificate=${ssl}\" > /dev/null"
  $license_cmd = "${wget} ${http_auth} \"${server_url}/license-go.xqy?licensee=${licensee}&license-key=${license_key}&ok=ok\" > /dev/null"
  $security_cmd = "${wget} ${http_auth} \"${server_url}/security-install-go.xqy?user=${admin_user}&password1=${admin_password}&password2=${admin_password}&realm=public\" > /dev/null"
  $security_upgrade_cmd = "${wget} ${http_auth} \"${server_url}/security-upgrade-go.xqy?ok=ok&ok.x=18&ok.y=17\" > /dev/null"
  $restart_service_cmd = '/sbin/service MarkLogic restart; /bin/sleep 5'

  if ($version =~ /^7/) {
    if $is_upgrade {
      include marklogic::version::7::upgrade
    } else {
      include marklogic::version::7::install
    }
  } elsif ($version =~ /^6/) {
    if $is_upgrade {
      include marklogic::version::6::upgrade
    } else {
      include marklogic::version::6::install
    }
  } else {
    fail()
  }
}
