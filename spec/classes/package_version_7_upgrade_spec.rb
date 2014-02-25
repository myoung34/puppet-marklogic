require 'spec_helper'

describe 'marklogic' do
  let(:params) {{ 
    :is_upgrade  => true,
    :licensee    => 'My Company',
    :license_key => 'foo-bar',
    :version     => '7.0-1',
  }}

  let(:title) { 'marklogic' }

  it { should contain_service('MarkLogic') }
  it { should_not contain_exec('fubar ML6 ec2 detection') }
  it { should_not contain_file('/bin/is-ec2.sh') }

  it { should contain_exec('upgrade_databases') }
  it { should contain_exec('manually_restart_service') }
  it { should contain_exec('restart ML') }

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
