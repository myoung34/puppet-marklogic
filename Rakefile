require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rake'
require 'rspec/core/rake_task'
require 'rspec-system/rake_task'
PuppetLint.configuration.send("disable_80chars") #1990 called and they want their 1024x768 resolution back.
PuppetLint.configuration.send("disable_class_parameter_defaults")

task :default => [:spec, :lint]
