$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support/json'
require 'active_support/core_ext'
require 'active_support/core_ext/hash'
require 'yaml'
require 'base64'
require 'riak/client_pb'

module Riak
  VERSION = '0.1.0'

  # Domain objects
  autoload :I18n,             'riak/i18n'
  autoload :Client,           'riak/client'
  autoload :Key,              'riak/key'
  autoload :RiakContent,      'riak/riak_content'
  autoload :Bucket,           'riak/bucket'
  autoload :MapReduce,        'riak/map_reduce'

  # Exceptions
  autoload :FailedRequest,    "riak/failed_request"
  autoload :FailedExchange,   "riak/failed_exchange"
  autoload :SiblingError,     "riak/sibling_error"

  # Mixins
  module Util
    autoload :Translation,    'riak/util/translation'
    autoload :MessageCode,    'riak/util/message_code'
    autoload :Encode,         'riak/util/encode'
    autoload :Decode,         'riak/util/decode'
  end
end