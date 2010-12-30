require 'bundler'

Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'


task :release => :spec

desc "Run Specs"
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern    = "spec/**/*_spec.rb"
  spec.verbose    = true
  spec.rspec_opts = ['--color']
end

require 'yard'

desc "Generate YARD docs"
YARD::Rake::YardocTask.new(:yard) do |t|
  t.files += ['lib/**/*.rb']
end

desc "Run Unit Specs Only"
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/riakpb/**/*_spec.rb"
end

namespace :spec do
  desc "Run Integration Specs Only"
  Rspec::Core::RakeTask.new(:integration) do |spec|
    spec.pattern = "spec/integration/**/*_spec.rb"
  end

  desc "Run All Specs"
  Rspec::Core::RakeTask.new(:all) do |spec|
    spec.pattern = Rake::FileList["spec/**/*_spec.rb"]
  end
end

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
