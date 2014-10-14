require 'spec_helper'

describe 'marklogic' do
  let(:params) {{ 
    :is_upgrade  => true,
    :licensee    => 'My Company',
    :license_key => 'foo-bar',
    :version     => '6.0-4',
  }}

  let(:title) { 'marklogic' }

  it { should have_class_count(4) }

  it { should_not contain_class('marklogic::version::6::install') }
  it { should     contain_class('marklogic::version::6::upgrade') }
  it { should_not contain_class('marklogic::version::7::install') }
  it { should_not contain_class('marklogic::version::7::upgrade') }

  it { should contain_service('MarkLogic').with_ensure('running').with_enable('true') }
  it { should_not contain_exec('fubar ML6 ec2 detection') }
  it { should_not contain_file('/bin/is-ec2.sh') }

  it { should contain_exec('restart ML') }

  it { should contain_exec('manually_restart_service').that_subscribes_to('Package[MarkLogic]').that_notifies('Exec[accept_license]') }
  it { should contain_exec('accept_license').that_notifies('Exec[upgrade_databases]') }
  it { should contain_exec('upgrade_databases') }
  it { should have_exec_resource_count(4) }

  it { should contain_package('MarkLogic') }
  it { should contain_package('gdb').with_ensure('present') }
  it { should contain_package('glibc-devel.i686').with_ensure('present') }
  it { should contain_package('glibc-devel.x86_64').with_ensure('present') }
  it { should contain_package('redhat-lsb').with_ensure('present') }
  it { should contain_package('wget').with_ensure('installed') }

  it { should contain_firewall('102 allow marklogic').with(
    'action' => 'accept',
    'port'   => [ 8000, 8001, 8002 ],
    'proto'  => 'tcp'
  )}
end
