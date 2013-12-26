# == Class: MarkLogic
#
# This class installs the MarkLogic server
#
# === Requires
#  [*puppetlabs-stdlib*](https://github.com/puppetlabs/puppetlabs-stdlib)
#  [*puppetlabs-firewall*](https://github.com/puppetlabs/puppetlabs-firewall)
#
# === Prerequisites
#  A YUM repository with the MarkLogic RPM packages must be configured for this module to function.
#  This is due to the [EULA](http://developer.marklogic.com/eula) which prevents redistribution of the packages,
#  forcing the user to maintain access to the packages.
#
# === Variables
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
#     activation process.
# [*licensee*]
#   The *licensee* information for the MarkLogic license information
# [*license_key*]
#   The *license key* information for the MarkLogic license information
# [*version*]
#   The version of MarkLogic to look for. MarkLogic will resemble *MarkLogic-{version}.x86_64.rpm*.
#
# === Examples
#
#  class { 'marklogic':
#    admin_password  => 'legit1!',
#    admin_user      => 'admin',
#    licensee        => 'My Company',
#    license_key     => '####-####-####-####-####',
#    version         => '6.0-1.1'
#  }
#
# === Authors
#
# Marcus Young <myoung34@my.apsu.edu>
#
class marklogic (
  $admin_user             = 'admin',
  $admin_password         = 'admin',
  $disable_ec2_detection  = false,
  $is_development_license = false,
  $is_upgrade             = false,
  $licensee,
  $license_key,
  $version,
) {

  class { 'marklogic':
    version               => $version,
    disable_ec2_detection => $disable_ec2_detection,
  }

  class { 'marklogic::activator':
    admin_user             => $admin_user,
    admin_password         => $admin_password,
    is_development_license => $is_development_license,
    is_upgrade             => $is_upgrade,
    licensee               => $licensee,
    license_key            => $license_key,
    version                => $version,
  }
}
