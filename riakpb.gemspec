# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "riakpb/version"

Gem::Specification.new do |s|
  s.name        = "riakpb"
  s.version     = Riakpb::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Scott Gonyea"]
  s.email       = ["me@sgonyea.com"]
  s.homepage    = %q{http://github.com/sgonyea/riak-pbclient}
  s.summary     = %q{riakpb is a protocol buffer client for Riak--the distributed database by Basho.}
  s.description = %q{riakpb is an all-ruby protocol buffer client for Riak--the distributed database by Basho.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '~> 3.0.0'
  s.add_dependency 'ruby_protobuf', '~> 0.4.8'

  s.add_dependency 'yard', '~> 0.6.4'

  s.add_development_dependency 'rspec', '~> 2.3.0'
  s.add_development_dependency 'i18n',  '~> 0.5.0'
end
