# == class Marklogic::version::6::install
#
# This class handles the activation of MarkLogic version 6 as a base install.
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
class marklogic::version::6::install inherits marklogic::activator {
  exec { 'enter_license':
    command     => $license_cmd,
    notify      => Exec['manually_restart_service'],
    path        => $::path,
    refreshonly => true,
    subscribe   => Package['MarkLogic'],
  }
  exec { 'manually_restart_service':
    command     => $restart_service_cmd,
    notify      => Exec['accept_license'],
    path        => $::path,
    refreshonly => true,
  }
  exec { 'accept_license':
    command     => $accept_cmd,
    notify      => Exec['initialize'],
    path        => $::path,
    refreshonly => true,
  }
  exec { 'initialize':
    command     => $initialize_cmd,
    notify      => Exec['manually_restart_service_again'],
    path        => $::path,
    refreshonly => true,
  }
  exec { 'manually_restart_service_again':
    command     => $restart_service_cmd,
    notify      => Exec['install_security_db'],
    path        => $::path,
    refreshonly => true,
  }
  exec { 'install_security_db':
    command     => $security_cmd,
    path        => $::path,
    refreshonly => true,
  }
}
