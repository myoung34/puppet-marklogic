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
  if ($version =~ /^7/) {
    $is_marklogic_version_7 = true
  } else {
    $is_marklogic_version_7 = false
  }

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

  $accept_cmd = "${wget} ${http_auth} \"${server_url}/agree-go.xqy?accepted-agreement=${license_type}&ok.x=32&ok.y=17&ok=accept\" > /dev/null"
  $initialize_cmd = "${wget} ${http_auth} \"${server_url}/initialize-go.xqy\" > /dev/null 2>&1"
  $join_cmd = "${wget} \"${server_url}/join-admin-go.xqy?new-server=${::fqdn}&new-server-port=8001&bind=7999&connect=7999&server=&port=8001&cancel=cancel&ssl-certificate=${ssl}\" > /dev/null"
  $license_cmd = "${wget} ${http_auth} \"${server_url}/license-go.xqy?licensee=${licensee}&license-key=${license_key}&ok=ok\" > /dev/null"
  $security_cmd = "${wget} ${http_auth} \"${server_url}/security-install-go.xqy?user=${admin_user}&password1=${admin_password}&password2=${admin_password}&realm=public\" > /dev/null"
  $security_upgrade_cmd = "${wget} ${http_auth} \"${server_url}/security-upgrade-go.xqy?ok=ok&ok.x=18&ok.y=17\" > /dev/null"

  if $is_marklogic_version_7 {
    if $is_upgrade {

      exec { 'upgrade_ML7_databases':
        command     => $security_upgrade_cmd,
        notify      => Exec['restart_ML7_after_upgrade'],
        refreshonly => true,
      }

      exec { 'restart_ML7_after_upgrade':
        command     => '/sbin/service MarkLogic restart',
        path        => $::path,
        refreshonly => true,
      }
    } else {

      exec { 'initialize_marklogic_7':
        command     => "/bin/sleep 4 && ${initialize_cmd}",
        notify      => Exec['restart_ML7_after_init'],
        refreshonly => true,
      }

      exec { 'restart_ML7_after_init':
        command     => '/sbin/service MarkLogic restart',
        notify      => Exec['join_marklogic_cluster'],
        path        => $::path,
        refreshonly => true,
      }

      exec { 'join_marklogic_cluster':
        command     => "/bin/sleep 2 && ${join_cmd}",
        notify      => Exec['install_marklogic_security'],
        refreshonly => true,
      }

      exec { 'install_marklogic_security':
        command     => $security_cmd,
        notify      => Exec['enter_marklogic_license_info'],
        refreshonly => true,
      }

      exec { 'enter_marklogic_license_info':
        command     => $license_cmd,
        refreshonly => true,
      }
    }

  } else {

    if $is_upgrade {
      exec { 'restart_ML_after_upgrade':
        command     => '/sbin/service MarkLogic restart',
        notify      => Exec['accept_upgrade_license'],
        path        => $::path,
      }

      exec { 'accept_upgrade_license':
        command     => "/bin/sleep 2 && ${accept_cmd}",
        notify      => Exec['upgrade_ML_databases'],
        refreshonly => true,
      }

      exec { 'upgrade_ML_databases':
        command     => $security_upgrade_cmd,
        refreshonly => true,
      }

    } else {
      exec { 'enter_marklogic_license_info':
        command     => $license_cmd,
        notify      => Exec['restart_ML_after_license'],
        refreshonly => true,
      }

      exec { 'restart_ML_after_license':
        command     => '/sbin/service MarkLogic restart',
        notify      => Exec['accept_license'],
        path        => $::path,
        refreshonly => true,
      }

      exec { 'accept_license':
        command     => "/bin/sleep 2 && ${accept_cmd}",
        notify      => Exec['initialize_marklogic'],
        refreshonly => true,
      }

      exec { 'initialize_marklogic':
        command     => $initialize_cmd,
        notify      => Exec['restart_ML_after_init'],
        refreshonly => true,
      }

      exec { 'restart_ML_after_init':
        command     => '/sbin/service MarkLogic restart',
        notify      => Exec['install_marklogic_security'],
        path        => $::path,
        refreshonly => true,
      }

      exec { 'install_marklogic_security':
        command     => "/bin/sleep 2 && ${security_cmd}",
        refreshonly => true,
      }
    }
  }
}
