require 'riakpb'

module Riakpb
  module Util
    
    module Encode
      
      # Construct a Request Message for Riakpb, which adheres to the following structure:
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

