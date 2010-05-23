# Copyright 2010 Sean Cribbs, Sonian Inc., and Basho Technologies, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
require 'riak'

module Riak
  module Util
    
    module Encode
      
      # Construct a Request Message for Riak, which adheres to the following structure:
      #
      #   00 00 00 07 09 0A 01 62 12 01 6B
      #   |----Len---|MC|----Message-----|
      #
      # @raise [TypeError] if an invalid hostname is given
      # @return [String] the assigned hostname
      def assemble_request(mc, msg='')
        raise TypeError, t("message_code_invalid")  unless mc.is_a?(Fixnum)
        raise TypeError, t("pb_message_invalid")    unless msg.is_a?(String)
        
        encode_message mc, msg
      end
      
      def encode_message(mc, msg='')
        message = [mc].pack('c') + msg
        
        message = [message.size].pack('N') + message
      end

    end
  end
end

