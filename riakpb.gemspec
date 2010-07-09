# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{riakpb}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Gonyea"]
  s.date = %q{2010-07-09}
  s.description = %q{riakpb is a protocol buffer client for Riakpb--the distributed database by Basho.}
  s.email = %q{me@inherentlylame.com}
  s.files = ["goog.csv", "History.txt", "lib/riakpb/bucket.rb", "lib/riakpb/client/rpc.rb", "lib/riakpb/client.rb", "lib/riakpb/client_pb.rb", "lib/riakpb/content.rb", "lib/riakpb/failed_exchange.rb", "lib/riakpb/failed_request.rb", "lib/riakpb/i18n.rb", "lib/riakpb/key.rb", "lib/riakpb/locale/en.yml", "lib/riakpb/map_reduce.rb", "lib/riakpb/sibling_error.rb", "lib/riakpb/util/decode.rb", "lib/riakpb/util/encode.rb", "lib/riakpb/util/message_code.rb", "lib/riakpb/util/translation.rb", "lib/riakpb.rb", "load_stocks.rb", "Manifest.txt", "Rakefile", "README.rdoc", "script/console", "script/destroy", "script/generate", "spec/riak/bucket_spec.rb", "spec/riak/client_spec.rb", "spec/riak/content_spec.rb", "spec/riak/key_spec.rb", "spec/riak/map_reduce_spec.rb", "spec/riak/rpc_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/aitrus/riak-pbclient}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{riakpb is a protocol buffer client for Riakpb--the distributed database by Basho.}
  s.test_files = ["spec/riak/bucket_spec.rb", "spec/riak/client_spec.rb", "spec/riak/content_spec.rb", "spec/riak/key_spec.rb", "spec/riak/map_reduce_spec.rb", "spec/riak/rpc_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.0.0.beta.9"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_runtime_dependency(%q<ruby_protobuf>, [">= 0.4.4"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.0.0.beta.9"])
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_dependency(%q<ruby_protobuf>, [">= 0.4.4"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.0.0.beta.9"])
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    s.add_dependency(%q<ruby_protobuf>, [">= 0.4.4"])
  end
end
