source 'https://rubygems.org'

group :development do
  gem 'puppet-blacksmith'
  gem 'rake',                    '>=0.9.2.2'
end

group :rake do
  gem 'coveralls', require: false
  gem 'puppet-lint'
  gem 'puppetlabs_spec_helper'
  gem 'rspec-puppet'
  gem 'rspec'
  gem 'beaker-rspec'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
