require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/riak'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'riak' do
  self.developer              'Scott Gonyea', 'me@sgonyea.com'
  self.rubyforge_name       = self.name
  self.summary              = 'riak-pcclient is a protocol buffer client for Riak--the distributed database by Basho.'
  self.url                  = 'http://github.com/aitrus/riak-pbclient'
end

require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run Unit Specs Only"
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/riak/**/*_spec.rb"
end

namespace :spec do
  desc "Run Integration Specs Only"
  Rspec::Core::RakeTask.new(:integration) do |spec|
    spec.pattern = "spec/integration/**/*_spec.rb"
  end

  desc "Run All Specs"
  Rspec::Core::RakeTask.new(:all) do |spec|
    spec.pattern = Rake::FileList["spec/**/*_spec.rb"] #"spec/**/*_spec.rb"
  end
end

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]

