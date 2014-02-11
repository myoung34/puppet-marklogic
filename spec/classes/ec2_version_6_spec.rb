require 'spec_helper'

describe 'marklogic' do
  let(:params) {{ 
    :disable_ec2_detection => true,
    :licensee              => 'My Company',
    :license_key           => 'foo-bar',
    :version               => '6.0-4',
  }}

  let(:title) { 'marklogic' }

  it { should contain_exec('fubar ML6 ec2 detection').with_refreshonly('true') }
  it { should_not contain_file('/bin/is-ec2.sh') }
end
