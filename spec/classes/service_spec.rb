require 'spec_helper'

describe 'marklogic' do
  let(:params) {{ 
    :licensee    => 'My Company',
    :license_key => 'foo-bar',
    :version     => '6.0-4',
  }}

  let(:title) { 'marklogic' }

  it { should contain_service('MarkLogic').without_restart }

end
