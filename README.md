puppet-marklogic
================
![Build Status](https://travis-ci.org/myoung34/puppet-marklogic.png?branch=master,dev)&nbsp;
[![Coverage Status](https://coveralls.io/repos/myoung34/puppet-marklogic/badge.png)](https://coveralls.io/r/myoung34/puppet-marklogic)&nbsp;
[![Puppet Forge](https://img.shields.io/puppetforge/v/myoung34/marklogic.svg)](https://forge.puppetlabs.com/myoung34/marklogic)
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/myoung34/puppet-marklogic/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

Puppet Module For Marklogic

About
=====

[MarkLogic](http://www.marklogic.com) is an Enterprise level NoSQL XML database driven to big data. It supports Windows, OSX, and RHEL/CentOS distributions, while this module is aimed at CentOS only (untested on RHEL).

Known AWS Issues
=================

[See this for a detailed explanation](https://github.com/myoung34/puppet-marklogic/wiki/Permanent-AWS-Issue)

Supported Versions (tested)
=================
## OS ##
* CentOS 6
    * MarkLogic Base install (MarkLogic not pre-installed)
        * 6.0-1.1
        * 6.0-2.3
        * 6.0-4
        * 6.0-4.1
        * 7.0-1
    * MarkLogic Upgrades
        * 6.0.1.1 *to* 6.0.2.3
        * 6.0.1.1 *to* 6.0.4
        * 6.0.1.1 *to* 6.0.4.1
        * 6.0.1.1 *to* 7.0-1
        * 6.0.2.3 *to* 6.0.4
        * 6.0.2.3 *to* 6.0.4.1
        * 6.0.2.3 *to* 7.0-1
        * 6.0.4   *to* 6.0-4.1
        * 6.0.4   *to* 7.0-1
        * 6.0.4.1 *to* 7.0-1

Prerequisites
=============

1. Yum repository with MarkLogic RPMs available (The EULA does not allow redistribution)
1. Valid license information

Quick Start
===========

       yumrepo { "my ML repo":
          baseurl  => "http://server/pulp/repos/marklogic/",
          descr    => "My MarkLogic Repository",
          enabled  => 1,
          gpgcheck => 0,
        }
        class { 'marklogic':
          admin_user             => 'admin', #defaults to admin
          admin_password         => 'admin', #defaults to admin
          disable_ec2_detection  => true,    #defaults to false
          is_development_license => true,    #defaults to false
          is_upgrade             => false,   #defaults to false
          licensee               => 'myname',#required
          license_key            => 'mykey', #required
          version                => '6.0-4', #required
        }

Hiera
=====

    marklogic::admin_password:         'admin'
    marklogic::admin_user:             'admin'
    marklogic::disable_ec2_detection:  true
    marklogic::is_development_license: true
    marklogic::is_upgrade:             false
    marklogic::licensee:               'my licensee'
    marklogic::license_key:            'my key'
    marklogic::version:                '6.0-4'

Testing
=====

* Run the default tests (puppet + lint)

        bundle install
        bundle exec rake

* Run the [beaker](https://github.com/puppetlabs/beaker) acceptance tests

Due to licensing issues, I cannot distribute the MarkLogic RPMs, or obviously my license information.
Also, due to the way beaker works, each spec file needs to run independently.

        $ for i in `ls spec/acceptance/*_spec.rb`; do echo $i; MARKLOGIC_YUM_URL=http://my.foo.com/yum/ MARKLOGIC_LICENSEE="my licensee" MARKLOGIC_KEY="1-2-3-4" bundle exec rspec $i | grep -A 150 Destroying\ vagrant\ boxes; done
