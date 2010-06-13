# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{riak}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Gonyea", "Sean Cribbs", "Basho Inc."]
  s.date = %q{2010-06-13}
  s.description = %q{This is a Ruby client for Riak, using protocol buffers instead of REST.  It offers some benefit in terms of speed and it abstracts Buckets/Keys differently than does the REST client.  Different != Better.}
  s.email = ["me@sgonyea.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/riak.rb", "lib/riak/client.rb", "lib/riak/client/rpc.rb", "lib/riak/client_pb.rb", "lib/riak/bucket.rb", "lib/riak/key.rb", "lib/riak/riak_content.rb", "lib/riak/i18n.rb", "lib/riak/locale/en.yml", "lib/riak/util/decode.rb", "lib/riak/util/encode.rb", "lib/riak/util/message_code.rb", "lib/riak/util/translation.rb", "lib/riak/failed_exchange.rb", "lib/riak/failed_request.rb", "lib/riak/sibling_error.rb", "script/console", "script/destroy", "script/generate", "spec/spec_helper.rb", "spec/riak/client_spec.rb", "spec/riak/rpc_spec.rb", "spec/riak/bucket_spec.rb", "spec/riak/key_spec.rb", "spec/riak/riak_content_spec.rb", "spec/riak/map_reduce_spec.rb"]
  s.homepage = %q{http://github.com/aitrus/riak-pbclient}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{riak}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{riak-pcclient is a protocol buffer client for Riak--the distributed database by Basho.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.0"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.0"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.0"])
  end
end
