require 'socket'

module Riak
  class Client
    class Rpc
      include Riak::Util::Encode
      include Riak::Util::Decode
      
      attr_reader :req_message, :response, :resp_message_code, :resp_messages
      
      def initialize(client)
        @client = client
      end

      def with_socket(&block)
        socket    = TCPSocket.open(@client.host, @client.port)
        out       = yield(socket)
        
        socket.close
        
        out
      end
      
      def call_riak(msg)
        
        with_socket do |socket|
          socket.send(msg, 0)
          self.response = socket.recv(2000)
        end
      end
      
      def request(mc, pb_msg=nil)
        if pb_msg.nil?
          @req_message = assemble_request mc
          
        elsif Protobuf::Message === pb_msg
          @req_message = assemble_request mc, pb_msg.serialize_to_string
          
        else
          raise TypeError, t("pb_message_invalid")
        end
        
        call_riak @req_message
        
        @response
      end
      
      def response=(value)
        @resp_message = value
        
        @resp_message_code, @response = decode_message(value)
        
      end
      
    end # class Client
  end # module Rpc
end # module RiakPbclient
