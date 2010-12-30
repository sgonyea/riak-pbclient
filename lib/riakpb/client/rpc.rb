# Special thanks to:
#
# - Radar in #ruby-lang
# - xnotdotorg / arilerner[at]gmail.com - 
#     http://blog.xnot.org/2008/11/16/communicating-from-ruby-to-erlang/
#
require 'socket'

module Riakpb
  class Client
    class Rpc
      include Riakpb::Util::MessageCode
      include Riakpb::Util::Translation
      include Riakpb::Util::Encode
      include Riakpb::Util::Decode

      RECV_LIMIT=1073741824

      attr_reader :req_message, :response, :resp_message_codes, :resp_message, :status

      # Establishes a Client ID with the Riakpb node, for the life of the RPC connection.
      # @param [Client] client the Riakpb::Client object in which this Rpc instance lives
      # @param [Fixnum] limit the max size of an individual TCPSocket receive call.  Need to fix, later.
      def initialize(client, limit=RECV_LIMIT)
        @status             = false
        @client             = client
        @limit              = limit
        @client_id          = request(Util::MessageCode::GET_CLIENT_ID_REQUEST).client_id
        @set_client_id      = Riakpb::RpbSetClientIdReq.new(:client_id => @client_id)

        # Request / Response Data
        @resp_message_codes = -1
        @resp_message       = []
        @req_message_code   = -1
        @req_message        = ''
        @response           = ''
      end

      # Clears the request / response data, in preparation for a new request
      def clear
        @resp_message_codes = -1
        @resp_message       = []
        @req_message_code   = -1
        @req_message        = ''
        @response           = ''
        @status             = false
        @buffer             = ''
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
        @set_c_id_req     ||= assemble_request( Util::MessageCode::SET_CLIENT_ID_REQUEST,
                                                @set_client_id.serialize_to_string)

        socket.write(@set_c_id_req)
        set_c_id_resp       = socket.sysread(@limit)

        resp_code, resp_msg = decode_message(set_c_id_resp)

        return(resp_code == Util::MessageCode::SET_CLIENT_ID_RESPONSE)
      end
      
      # Sends the request to the riak node
      # @param [Fixnum] mc The message code that identifies the request
      # @param [Protobuf::Message] pb_msg The protobuf message, if applicable, for the message code
      # @return [True/False] whether or not the set client id request succeeded
      def request(mc, pb_msg=nil)
        clear

        @req_message_code = mc
        @response         = RESPONSE_CLASS_FOR[mc].new unless RESPONSE_CLASS_FOR[mc].nil?

        with_socket do |socket|
          begin
            begin
              @req_message  = assemble_request mc, pb_msg.serialize_to_string
            rescue NoMethodError
              @req_message  = assemble_request mc
            end

            socket.write(@req_message)
            self.parse_response socket.sysread(@limit)

          end while(false == (@response[:done] rescue true))

          socket.flush
        end # with_socket

        return(@response)
      end # stream_request

      # Handles the response from the Riakpb node
      # @param [String] value The message returned from the Riakpb node over the TCP Socket
      # @return [Protobuf::Message] @response the processed response (if any) from the Riakpb node
      def parse_response(value)
        @resp_message << value

        value = @buffer + value

#        return {:done => false} if message_remaining?(@resp_message)

        response_chunk, @resp_message_codes, @buffer = decode_message(value)

        @resp_message_codes.each do |resp_mc|
          if resp_mc.equal?(ERROR_RESPONSE)
            raise FailedRequest.new(MC_RESPONSE_FOR[@req_message_code], @resp_message_codes, response_chunk)
          end

          # The below should never really happen
          if resp_mc != MC_RESPONSE_FOR[@req_message_code]
            raise FailedExchange.new(MC_RESPONSE_FOR[@req_message_code], @resp_message_codes, response_chunk, "failed_request")
          end
        end
        
        if response_chunk.size > 0
          @response.parse_from_string response_chunk
        end

        @status = true
        return(@response)
      end

    end # class Client
  end # module Rpc
end # module RiakpbPbclient
