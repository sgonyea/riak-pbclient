require 'socket'

module Riak
  class Client
    class Rpc
      include Riak::Util::MessageCode
      include Riak::Util::Encode
      include Riak::Util::Decode
      
      attr_reader :req_message, :response, :resp_message_code, :resp_message, :responses
      
      def initialize(client)
        @client             = client
        @client_id          = request(Riak::Util::MessageCode::GET_CLIENT_ID_REQUEST,
                                      nil,
                                      Riak::RpbGetClientIdResp
                              ).client_id
        @set_client_id      = Riak::RpbSetClientIdReq.new(:client_id => @client_id)
        
        # Request / Response Data
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
        socket              = TCPSocket.open(@client.host, @client.port)
        set_client_id(socket) if @set_client_id
        
        out                 = yield(socket)
        socket.close
        
        return(out)
      end
      
      
      def set_client_id(socket)
        set_c_id_req  = assemble_request( Riak::Util::MessageCode::SET_CLIENT_ID_REQUEST,
                                          @set_client_id.serialize_to_string)

        socket.send(set_c_id_req, 0)
        set_c_id_resp = socket.recv(2000)
        
        resp_code, resp_msg = decode_message(set_c_id_resp)
        
        return resp_code == Riak::Util::MessageCode::SET_CLIENT_ID_RESPONSE
      end
      
      
      def request(mc, pb_msg=nil, pb_resp_class=nil)
        clear
        
        raise TypeError, t("pb_message_invalid") unless 
          pb_msg.is_a?(Protobuf::Message) or
          pb_msg.is_a?(NilClass)
        
        
        @response           = pb_resp_class.new rescue nil
        
        with_socket do |socket|
          begin
            @req_message  = assemble_request mc, (pb_msg.serialize_to_string rescue '')
            
            socket.send(@req_message, 0)
            self.response = socket.recv(2000)
            
          end while(false == @response.done rescue false)
          
          return(@response)
        end # with_socket
      end # stream_request
      
      
      def response=(value)
        @resp_message         = value
        
        @resp_message_code, response_chunk = decode_message(value)
        
        if response_chunk.size > 0
          @response.parse_from_string response_chunk
        end
        
        return(@response)
      end
      
    end # class Client
  end # module Rpc
end # module RiakPbclient
