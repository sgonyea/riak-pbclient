require 'riak'

module Riak
  module Util

    module Decode
      PLEN  = (0..3)
      PBMC  = PLEN.count
      POFF  = (PBMC+1)

      def decode_message(message)
        pb_len  = 0
        pb_mc   = ''
        pb_msg  = ''

        until message.empty?
          pb_len  = message[PLEN].unpack('N')[0]    # message[0..3]unpack('N')[0]
          pb_mc   = pb_mc + message[PBMC]           # prior message codes + message[4]

          prange  = POFF..(pb_len+3)                # range for the start->finish of the pb message
          mrange  = (pb_len+4)..(message.size-1)    # range for any remaining portions of message

          if(prange.count != message[prange].size)
            raise FailedExchange.new(prange.count, message[prange].size, message[prange], "decode_error")
          end

          pb_msg  = pb_msg + message[prange]
          message = message[mrange]      # message[(5+pb_len)..(message.size)]
        end

        [pb_msg, pb_mc.unpack("c" * pb_mc.size)]
      end

    end # module Decode
  end
end

