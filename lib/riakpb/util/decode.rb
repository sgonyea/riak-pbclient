require 'riakpb'

module Riakpb
  module Util

    module Decode
      PLEN  = (0..3)
      PBMC  = PLEN.count
      POFF  = (PBMC+1)

      def decode_message(message)
        
        pb_len  = 0
        pb_mc   = [] 
        pb_msg  = ''
        remain  = ''

        until message.empty?
          pb_len  = message[PLEN].unpack('N')[0]    # message[0..3]unpack('N')[0]
          pb_mc   = pb_mc + [message[PBMC]]           # prior message codes + message[4]

          prange  = POFF..(pb_len+3)                # range for the start->finish of the pb message
          mrange  = (pb_len+4)..(message.size-1)    # range for any remaining portions of message

          break if(prange.count > message[prange].size)

          pb_msg  = pb_msg + message[prange]
          message = message[mrange]      # message[(5+pb_len)..(message.size)]
        end

        [pb_msg, pb_mc, message]
      end

      def message_remaining?(message)
        pb_len  = message[PLEN].unpack('N')[0]
        msg_len = message.size - PBMC

        puts "pb_len:#{pb_len}"
        puts "msg_len:#{msg_len}"
        puts "message:#{message.inspect}"

        return false  if pb_len  == msg_len
        return true   if pb_len   > msg_len

        return message_remaining?(message[(pb_len+4)..(msg_len-1)])
      end
    end # module Decode
  end
end

