# Copyright 2010, Scott Gonyea
#
# Special thanks to:
#
# - Radar in #ruby-lang
# - xnotdotorg / arilerner[at]gmail.com - 
#     http://blog.xnot.org/2008/11/16/communicating-from-ruby-to-erlang/
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
require 'socket'

module Riak
  class Client
    class Rpc
      include Riak::Util::MessageCode
      include Riak::Util::Translation
      include Riak::Util::Encode
      include Riak::Util::Decode
      
      attr_reader :req_message, :response, :resp_message_code, :resp_message, :responses
      
      # Establishes a Client ID with the Riak node, for the life of the RPC connection.
      # @param [Client] the Riak::Client object in which this Rpc instance lives
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
      
      # Clears the request / response data, in preparation for a new request
      def clear
        @resp_message_code  = -1
        @resp_message       = ''
        @req_message        = ''
        @response           = ''
        @responses          = []
      end
      
      # Opens a TCPSocket connection with the riak host/node
      # @yield [TCPSocket] hands off the socket connection
      # @return [TCPSocket] data that was exchanged with the host/node
      def with_socket(&block)
        socket              = TCPSocket.open(@client.host, @client.port)
        set_client_id(socket) if @set_client_id
        
        out                 = yield(socket)
        socket.close
        
        return(out)
      end
      
      # Sets the Client ID for the TCPSocket session
      # @param [TCPSocket] socket connection for which the Client ID will be set
      # @return [True/False] whether or not the set client id request succeeded
      def set_client_id(socket)
        @set_c_id_req     ||= assemble_request( Riak::Util::MessageCode::SET_CLIENT_ID_REQUEST,
                                                @set_client_id.serialize_to_string)

        socket.send(@set_c_id_req, 0)
        set_c_id_resp       = socket.recv(2000)
        
        resp_code, resp_msg = decode_message(set_c_id_resp)
        
        return resp_code == Riak::Util::MessageCode::SET_CLIENT_ID_RESPONSE
      end
      
      # Sends the request to the riak node
      # @param [Fixnum] mc The message code that identifies the request
      # @param [Protobuf::Message] pb_msg The protobuf message, if applicable, for the message code
      # @param [Protobuf::Message] pb_msg The protobuf message, if applicable, for the message code
      # @return [True/False] whether or not the set client id request succeeded
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
      
      
      # Handles the response from the Riak node
      # @param [String] value The message returned from the Riak node over the TCP Socket
      # @return [Protobuf::Message] @response the processed response (if any) from the Riak node
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
