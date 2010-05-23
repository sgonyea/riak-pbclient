$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'riak/client_pb'

module Riak
  VERSION = '0.0.1'
  
  # Domain objects
  autoload :ClientPb,         'riak/client_pb'
  autoload :Client,           'riak/client'
  autoload :I18n,             'riak/i18n'

  module Util
    autoload :Translation,    'riak/util/translation'
    autoload :Encode,         'riak/util/encode'
    autoload :Decode,         'riak/util/decode'
    autoload :MessageCode,    'riak/util/message_code'
  end
end