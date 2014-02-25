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
  exec { 'initialize':
    command     => $initialize_cmd,
    path        => $::path,
  }
  exec { 'install_security_db':
    command     => $security_cmd,
    path        => $::path,
  }
  exec { 'enter_license':
    command     => $license_cmd,
    path        => $::path,
  }
  exec { 'accept_license':
    command     => $accept_cmd,
    path        => $::path,
  }
  exec {'manually_restart_service':
    command     => $restart_service_cmd,
    path        => $::path,
  }
  exec {'manually_restart_service_again':
    command     => $restart_service_cmd,
    path        => $::path,
  }

  # The service needs to be restarted mid-run. Making a call to
  # Service['MarkLogic'] causes a cycle chain if used twice in one chain.
  Package['MarkLogic'] -> Exec['enter_license'] ->
    Exec['manually_restart_service'] -> Exec['accept_license'] ->
      Exec['initialize'] -> Exec['manually_restart_service_again'] ->
        Exec['install_security_db']
}
