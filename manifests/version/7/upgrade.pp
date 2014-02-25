# == class Marklogic::version::7::upgrade
#
# This class handles the activation of MarkLogic version 7 as an upgrade.
#
# === Requires
#  [*puppetlabs-stdlib*](https://github.com/puppetlabs/puppetlabs-stdlib)
#  [*puppetlabs-firewall*](https://github.com/puppetlabs/puppetlabs-firewall)
#
# === Parameters
#
# === Examples
#
# This class should not be called directly. It inherits the base activator.
#
# === Authors
#
# Marcus Young <myoung34@my.apsu.edu>
#
class marklogic::version::7::upgrade inherits marklogic::activator {
  exec { 'upgrade_databases':
    command     => $security_upgrade_cmd,
    path        => $::path,
  }
  exec {'manually_restart_service':
    command     => $restart_service_cmd,
    path        => $::path,
  }

  Package['MarkLogic'] -> Exec['upgrade_databases'] ->
    Exec['manually_restart_service']
}
