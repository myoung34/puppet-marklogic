require 'spec_helper_acceptance'

describe 'marklogic class' do
  describe 'install 6.0-2.3' do
    it 'should work with no errors' do
      pp = <<-EOS
        yumrepo { "marklogic":
          baseurl         => "#{ENV['MARKLOGIC_YUM_URL']}",
          descr           => "My MarkLogic Repository",
          enabled         => 1,
          gpgcheck        => 0,
          metadata_expire => 10,
        }

        class { 'marklogic':
          admin_user             => 'admin', #defaults to admin
          admin_password         => 'legit', #defaults to admin
          disable_ec2_detection  => true,    #defaults to false
          is_development_license => true,    #defaults to false
          is_upgrade             => false,   #defaults to false
          licensee               => "#{ENV['MARKLOGIC_LICENSEE']}",#required
          license_key            => "#{ENV['MARKLOGIC_KEY']}", #required
          version                => '6.0-2.3', #required
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      shell("sleep 30 && curl -s -o /tmp/mlapi_admin.html -w '%{http_code}' --digest -u admin:legit http://localhost:8001") do |result|
        assert_match result.stdout, '200', 'Admin UI did not return a 200 OK'
      end

      shell("rdom () { local IFS=\\> ; read -d \\< E C ;}; while rdom; do if [[ $E = title ]]; then echo $C; fi; done < /tmp/mlapi_admin.html") do |result|
        assert_match /^System Summary - MarkLogic Server/, result.stdout, 'Admin UI is not at the main control page.'
      end
    end
  end
end
