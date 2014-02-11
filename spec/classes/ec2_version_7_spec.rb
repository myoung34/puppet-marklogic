require 'spec_helper'

describe 'marklogic' do
  let(:params) {{ 
    :disable_ec2_detection => true,
    :licensee              => 'My Company',
    :license_key           => 'foo-bar',
    :version               => '7.0-1',
  }}

  let(:title) { 'marklogic' }

  it { should_not contain_exec('fubar ML6 ec2 detection') }
  it { should contain_file('/bin/is-ec2.sh').with_replace('false') }
end
