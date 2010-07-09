# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{riakpb}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Gonyea"]
  s.date = %q{2010-07-08}
  s.description = %q{riakpb is a protocol buffer client for Riak--the distributed database by Basho.}
  s.email = %q{me@inherentlylame.com}
  s.files = ["goog.csv", "History.txt", "lib/riak/bucket.rb", "lib/riak/client/rpc.rb", "lib/riak/client.rb", "lib/riak/client_pb.rb", "lib/riak/failed_exchange.rb", "lib/riak/failed_request.rb", "lib/riak/i18n.rb", "lib/riak/key.rb", "lib/riak/locale/en.yml", "lib/riak/map_reduce.rb", "lib/riak/riak_content.rb", "lib/riak/sibling_error.rb", "lib/riak/util/decode.rb", "lib/riak/util/encode.rb", "lib/riak/util/message_code.rb", "lib/riak/util/translation.rb", "lib/riak.rb", "load_stocks.rb", "Manifest.txt", "Rakefile", "README.rdoc", "riakpb.gemspec", "script/console", "script/destroy", "script/generate", "spec/riak/bucket_spec.rb", "spec/riak/client_spec.rb", "spec/riak/key_spec.rb", "spec/riak/map_reduce_spec.rb", "spec/riak/riak_content_spec.rb", "spec/riak/rpc_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/aitrus/riak-pbclient}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{riakpb is a protocol buffer client for Riak--the distributed database by Basho.}
  s.test_files = ["spec/riak/bucket_spec.rb", "spec/riak/client_spec.rb", "spec/riak/key_spec.rb", "spec/riak/map_reduce_spec.rb", "spec/riak/riak_content_spec.rb", "spec/riak/rpc_spec.rb", "spec/spec_helper.rb"]

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
