require 'spec_helper_system'

shared_examples "a marklogic instance" do |version, is_upgrade=false|
  context 'should install with no errors' do
    mlConfig = YAML::load(File.read(ENV['HOME'] + '/.marklogic.yml')) 
    pp = "
        class { 'marklogic':
          is_upgrade             => #{is_upgrade},
          is_development_license => #{mlConfig['is_development_license']},
          licensee               => '#{mlConfig['licensee']}',
          license_key            => '#{mlConfig['license_key']}',
          version                => '#{version}',
        }
      "

    context puppet_apply(pp) do |r|
      its(:stderr) { should be_empty }
      its(:refresh) { should be_nil }
    end
  end
end

describe 'install' do
  it_behaves_like "a marklogic instance", node.options['marklogicVersion']
end

unless node.options['nextVersion'].nil? then
  describe "upgrade to #{node.options['nextVersion']}" do
    it_behaves_like "a marklogic instance", node.options['nextVersion'], true
  end
end
