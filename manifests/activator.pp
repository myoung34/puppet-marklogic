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
  $accept_cmd = $::should_accept_license ? {
    true    => "${wget} ${http_auth} \"${server_url}/agree-go.xqy?accepted-agreement=${license_type}&ok.x=32&ok.y=17&ok=accept\" > /dev/null",
    default => 'echo noop > /dev/null',
  }
  $initialize_cmd = $::should_initialize ? {
    true    => "${wget} ${http_auth} \"${server_url}/initialize-go.xqy\" > /dev/null 2>&1",
    default => 'echo noop > /dev/null',
  }
  $join_cmd = $::should_join ? {
    true    => "${wget} \"${server_url}/join-admin-go.xqy?new-server=${::fqdn}&new-server-port=8001&bind=7999&connect=7999&server=&port=8001&cancel=cancel&ssl-certificate=${ssl}\" > /dev/null",
    default => 'echo noop > /dev/null'
  }
  $license_cmd = $::should_enter_license ? {
    true    => "${wget} ${http_auth} \"${server_url}/license-go.xqy?licensee=${licensee}&license-key=${license_key}&ok=ok\" > /dev/null",
    default => 'echo noop > /dev/null',
  }
  $security_cmd = $::should_install_security ? {
    true    => "${wget} ${http_auth} \"${server_url}/security-install-go.xqy?user=${admin_user}&password1=${admin_password}&password2=${admin_password}&realm=public\" > /dev/null",
    default => 'echo noop > /dev/null',
  }
  $security_upgrade_cmd = $::should_upgrade_security ? {
    true    => "${wget} ${http_auth} \"${server_url}/security-upgrade-go.xqy?ok=ok&ok.x=18&ok.y=17\" > /dev/null",
    default => 'echo noop > /dev/null',
  }
  $restart_service_cmd = $::should_restart_service ? {
    true    => '/sbin/service MarkLogic restart',
    default => 'echo noop > /dev/null',
  }
  exec { 'sleep':
    command     => '/bin/sleep 3',
    path        => $::path,
    refreshonly => true,
    subscribe   => Service['MarkLogic'],
  }
  exec { 'upgrade_databases':
    command     => $security_upgrade_cmd,
    path        => $::path,
    refreshonly => true,
  }
  exec { 'initialize':
    command     => $initialize_cmd,
    path        => $::path,
    refreshonly => true,
  }
  exec { 'join_cluster':
    command     => $join_cmd,
    path        => $::path,
    refreshonly => true,
  }
  exec { 'install_security_db':
    command     => $security_cmd,
    path        => $::path,
    refreshonly => true,
  }
  exec { 'enter_license':
    command     => $license_cmd,
    path        => $::path,
    refreshonly => true,
  }
  exec { 'accept_license':
    command     => $accept_cmd,
    path        => $::path,
    refreshonly => true,
  }
  exec {'manually_restart_service':
    command     => $restart_service_cmd,
    path        => $::path,
    refreshonly => true,
  }



  if ($version =~ /^7/) {
    if $is_upgrade {
      $should_upgrade_security = true

      Exec['upgrade_databases'] -> Service['MarkLogic']
    } else {
      $should_initialize = true
      $should_join = true
      $should_enter_license = true
      $should_install_security = true

      Exec['initialize'] -> Service['MarkLogic'] -> Exec['join_cluster'] -> Exec['install_security_db'] -> Exec['enter_license']
    }
  } elsif ($version =~ /^6/) {
    if $is_upgrade {
      $should_enter_license = true
      $should_upgrade_security = true

      Service['MarkLogic'] ->  Exec['accept_license'] -> Exec['upgrade_databases']
    } else {
      # The service needs to be restarted mid-run. Making a call to Service['MarkLogic'] causes a cycle chain if used twice in one chain.
      $should_enter_license = true
      $should_accept_license = true
      $should_initialize = true
      $should_install_security = true

      Exec['enter_license'] -> Exec['manually_restart_service'] -> Exec['accept_license'] -> Exec['initialize'] -> Service['MarkLogic'] -> Exec['install_security_db']
    }
  } else {
    fail()
  }
}
