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
    
    module Decode
      
      private
      
      def decode_message(message)
        size = message[0..3].unpack('N')[0]
        
        raise ResponseError t('response_size_mismatch') if((size + 4) != message.size)
        
        message[4..(message.size)].unpack('ca#{size-1}')
      end

    end 
  end
end

