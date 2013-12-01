# == Class marklogic::marklogic
#
# This define handles the packages and prerequisites for installing MarkLogic
#
# === Requires
#  [*puppetlabs-stdlib*](https://github.com/puppetlabs/puppetlabs-stdlib)
#  [*puppetlabs-firewall*](https://github.com/puppetlabs/puppetlabs-firewall)
#
# === Parameters
#
# [*version*]
#   The version of MarkLogic to look for. MarkLogic will resemble *MarkLogic-{version}.x86_64.rpm*.
#
# === Examples
#
# Provide some examples on how to use this type:
#
#   class { 'marklogic::marklogic':
#     version => '6.0-4',
#   }
#
# === Authors
#
# Marcus Young <myoung34@my.apsu.edu>
#
class marklogic::marklogic (
  $version,
) {
  firewall { '102 allow marklogic':
    action => accept,
    port   => [
      # ML Server ports
      8000, 8001, 8002,
    ],
    proto  => tcp,
  }

  $prerequisite_packages = [
    'gdb',
    'glibc-devel.i686',
    'glibc-devel.x86_64',
    'redhat-lsb',
  ]

  package { $prerequisite_packages:
    ensure   => present,
    provider => yum,
  }

  package { 'MarkLogic':
    ensure   => $version,
    notify   => Class['marklogic::activator'],
    provider => yum,
    require  => Package[$prerequisite_packages],
  }

  exec {'restart ML':
    command     => 'service MarkLogic restart',
    path        => $::path,
    subscribe   => [
      Package['MarkLogic'],
    ],
    refreshonly => true,
  }
}
