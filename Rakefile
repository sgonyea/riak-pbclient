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
  self.developer              'Scott Gonyea', 'gonyea@gmail.com'
  self.rubyforge_name       = self.name
  self.summary              = 'riak-pcclient is a protocol buffer client for Riak--the distributed database by Basho.'
  self.url                  = 'http://github.com/aitrus/riak-pbclient'
  # self.extra_deps         = [['activesupport','>= 2.0.2']]
end


require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]

