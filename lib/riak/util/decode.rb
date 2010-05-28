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

      def decode_message(message)
        msg_len = message[0..3].unpack('N')[0]
        msgsize = message.size

        if((msg_len + 4) != msgsize)
          puts "-------"
          puts "msg_len: #{msg_len}"
          puts "msgsize: #{msgsize}"
          puts "#{message.inspect}"
          puts "-------"
          raise FailedExchange.new((msg_len + 4), msgsize, message, "decode_error")
        end

        message[4..(message.length-1)].unpack("ca#{msg_len-1}")
      end

    end # module Decode
  end
end

