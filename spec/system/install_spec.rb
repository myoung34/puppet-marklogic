require 'spec_helper_system'

shared_examples "a marklogic instance" do |version, is_upgrade=false, is_ec2_instance=false|
  context 'should install with no errors' do
    ml_config = YAML::load(File.read(ENV['HOME'] + '/.marklogic.yml'))
    pp = "
        class { 'marklogic':
          disable_ec2_detection  => #{is_ec2_instance},
          is_upgrade             => #{is_upgrade},
          is_development_license => #{ml_config['is_development_license']},
          licensee               => '#{ml_config['licensee']}',
          license_key            => '#{ml_config['license_key']}',
          version                => '#{version}',
        }
      "

    context puppet_apply(pp) do |r|
      its(:stderr) { should be_empty }
      its(:refresh) { should be_nil }
    end

    context 'ec2 detection' do
      if is_ec2_instance
        describe file('/etc/sysconfig/MarkLogic'), :if => version =~ /^6/ do
          it { should be_file }
          it { should contain "/proc/fake" }
          it { should_not contain "/proc/xen" }
        end

        describe file('/bin/is-ec2.sh'), :if => version =~ /^6/ do
          it { should_not be_file }
        end

        describe file('/etc/sysconfig/MarkLogic'), :if => version =~ /^7/ do
          it { should be_file }
        end

        describe file('/bin/is-ec2.sh'), :if => version =~ /^7/ do
          it { should be_file }
          it { should contain "exit 1" }
        end

      else
        describe file('/etc/sysconfig/MarkLogic'), :if => version =~ /^6/ do
          it { should be_file }
          it { should contain "/proc/xen" }
          it { should_not contain "/proc/fake" }
        end

        describe file('/bin/is-ec2.sh'), :if => version =~ /^6/ do
          it { should_not be_file }
        end
      end
    end
  end
end

describe 'install' do
  it_behaves_like "a marklogic instance", node.options['marklogic_version'], false, false
end

unless node.options['next_version'].nil? then
  describe "upgrade to #{node.options['next_version']}" do
    it_behaves_like "a marklogic instance", node.options['next_version'], true, false
    it_behaves_like "a marklogic instance", node.options['next_version'], true, true
  end
end
