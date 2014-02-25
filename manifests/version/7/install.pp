# == class Marklogic::version::7::install
#
# This class handles the activation of MarkLogic version 7 as a base install.
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
class marklogic::version::7::install inherits marklogic::activator {
  exec { 'initialize':
    command     => $initialize_cmd,
    path        => $::path,
  }
  exec { 'join_cluster':
    command     => $join_cmd,
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
  exec { 'manually_restart_service':
    command     => $restart_service_cmd,
    path        => $::path,
  }

  Package['MarkLogic'] -> Exec['initialize'] ->
    Exec['manually_restart_service'] -> Exec['join_cluster'] ->
      Exec['install_security_db'] -> Exec['enter_license']
}
