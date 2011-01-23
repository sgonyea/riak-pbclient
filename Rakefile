require 'bundler'

Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
require 'yard'

task :release => :spec

desc "Generate YARD docs"
YARD::Rake::YardocTask.new(:yard) do |t|
  t.files += ['lib/**/*.rb']
end

desc "Run Specs"
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern    = "spec/**/*_spec.rb"
  spec.verbose    = true
  spec.rspec_opts = ['--color']
end
