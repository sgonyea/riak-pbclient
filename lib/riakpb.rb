$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support/json'
require 'active_support/core_ext'
require 'active_support/core_ext/hash'
require 'yaml'
require 'base64'
require 'riakpb/client_pb'

module Riakpb
  # Domain objects
  autoload :I18n,             'riakpb/i18n'
  autoload :Client,           'riakpb/client'
  autoload :Key,              'riakpb/key'
  autoload :Content,          'riakpb/content'
  autoload :Bucket,           'riakpb/bucket'
  autoload :MapReduce,        'riakpb/map_reduce'

  # Exceptions
  autoload :FailedRequest,    "riakpb/failed_request"
  autoload :FailedExchange,   "riakpb/failed_exchange"
  autoload :SiblingError,     "riakpb/sibling_error"

  # Mixins
  module Util
    autoload :Translation,    'riakpb/util/translation'
    autoload :MessageCode,    'riakpb/util/message_code'
    autoload :Encode,         'riakpb/util/encode'
    autoload :Decode,         'riakpb/util/decode'
  end
end
