module Riak
  module Util
    module MessageCode
      ERROR_RESPONSE            = 0
    
      PING_REQUEST              = 1
      PING_RESPONSE             = 2
    
      GET_CLIENT_ID_REQUEST     = 3
      GET_CLIENT_ID_RESPONSE    = 4
    
      SET_CLIENT_ID_REQUEST     = 5
      SET_CLIENT_ID_RESPONSE    = 6
    
      GET_SERVER_INFO_REQUEST   = 7
      GET_SERVER_INFO_RESPONSE  = 8
    
      GET_REQUEST               = 9
      GET_RESPONSE              = 10
    
      PUT_REQUEST               = 11
      PUT_RESPONSE              = 12
    
      DEL_REQUEST               = 13
      DEL_RESPONSE              = 14
    
      LIST_BUCKETS_REQUEST      = 15
      LIST_BUCKETS_RESPONSE     = 16
    
      LIST_KEYS_REQUEST         = 17
      LIST_KEYS_RESPONSE        = 18
      
      GET_BUCKET_REQUEST        = 19
      GET_BUCKET_RESPONSE       = 20
      
      SET_BUCKET_REQUEST        = 21
      SET_BUCKET_RESPONSE       = 22
      
      MAP_REDUCE_REQUEST        = 23
      MAP_REDUCE_RESPONSE       = 24
    end
  end
end