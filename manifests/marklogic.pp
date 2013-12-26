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
  $disable_ec2_detection = false,
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

  if $disable_ec2_detection {
    if ($version =~ /^6/) {
      # All of my wat. MarkLogic 6 has a hardcoded /dev/sdf in
      # /etc/sysconfig/MarkLogic that is set if it's detected as an EC2.
      # This means.....the init.d script could fail because it indefinitely waits for
      # /dev/sdf to become a block device. Or it could mean that if you have a /dev/sdf
      # that has a purpose other than MarkLogic, it's not the datadirectory for it anyway.
      # the service if they decide to automagically start the service during the RPM
      # Let's highjack the entry point and force the EC2 check to fail. Stay classy.
      exec { 'fubar ML6 ec2 detection':
        before      => Exec['restart ML'],
        command     => 'sed -i.bak "s/\/proc\/xen/\/proc\/fake/g" /etc/sysconfig/MarkLogic',
        path        => $::path,
        subscribe   => Package['MarkLogic'],
      }
    } elsif ($version =~ /^7/) {
      # MarkLogic V7 on EC2 requires Java, but not to run. Unknown what for, but
      # it's used highly in /opt/MarkLogic/mlcmd/bin/mlcmd. It seems to only be
      # needed if using EC2 optimization. To disable EC2 detection and get running
      # quickly, you can use their 'is-ec2.sh' to return 1, causing the init.d to fail
      # detection. This script is loaded last in the path, so creating one
      # higher up (/bin) will cause this detection to fail. Note to MarkLogic if you ever
      # decide to read this, you allowed overwriting of variables in /etc/marklogic.cnf, but
      # you immediately give a giant middle finger by overwriting all the values.
      file {'/bin/is-ec2.sh':
        ensure  => present,
        before  => Package['MarkLogic'],
        content => template('marklogic/is-ec2.sh.erb'),
        mode    => '0700',
      }
    } else {
      fail()
    }
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
