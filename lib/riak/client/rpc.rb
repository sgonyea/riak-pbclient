require 'socket'

module Riak
  class Client
    class Rpc
      include Riak::Util::Encode
      include Riak::Util::Decode
      
      attr_reader :req_message, :response, :resp_message_code, :resp_message, :responses
      
      def initialize(client)
        @client             = client
        @resp_message_code  = -1
        @resp_message       = ''
        @req_message        = ''
        @response           = ''
        @responses          = []
      end
      
      def clear
        @resp_message_code  = -1
        @resp_message       = ''
        @req_message        = ''
        @response           = ''
        @responses          = []
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
      
      def request(mc, pb_msg=nil, pb_resp_class=nil)
        clear
        
        raise TypeError, t("pb_message_invalid") unless 
          pb_msg.is_a?(Protobuf::Message) or
          pb_msg.is_a?(NilClass)
        
        
        @response = pb_resp_class.new rescue nil
        
        with_socket do |socket|
          begin
            @req_message = assemble_request mc, (pb_msg.serialize_to_string rescue '')
            
            socket.send(@req_message, 0)
            self.response = socket.recv(2000)
            
          end while(false == @response.done rescue false)
        end # with_socket
      end # stream_request
      
      def response=(value)
        @resp_message = value
        
        @resp_message_code, response_chunk = decode_message(value)
        
        if response_chunk.size > 0
          @response.parse_from_string response_chunk
        end
      end
      
    end # class Client
  end # module Rpc
end # module RiakPbclient
