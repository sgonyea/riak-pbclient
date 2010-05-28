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
      
      MC_RESPONSE_FOR           = {
        PING_REQUEST            =>  PING_RESPONSE,
        GET_CLIENT_ID_REQUEST   =>  GET_CLIENT_ID_RESPONSE,
        SET_CLIENT_ID_REQUEST   =>  SET_CLIENT_ID_RESPONSE,
        GET_SERVER_INFO_REQUEST =>  GET_SERVER_INFO_RESPONSE,
        GET_REQUEST             =>  GET_RESPONSE,
        PUT_REQUEST             =>  PUT_RESPONSE,
        DEL_REQUEST             =>  DEL_RESPONSE,
        LIST_BUCKETS_REQUEST    =>  LIST_BUCKETS_RESPONSE,
        LIST_KEYS_REQUEST       =>  LIST_KEYS_RESPONSE,
        GET_BUCKET_REQUEST      =>  GET_BUCKET_RESPONSE,
        SET_BUCKET_REQUEST      =>  SET_BUCKET_RESPONSE,
        MAP_REDUCE_REQUEST      =>  MAP_REDUCE_RESPONSE
      }
      
      RESPONSE_CLASS_FOR        = {
        PING_REQUEST            =>  nil,
        GET_CLIENT_ID_REQUEST   =>  Riak::RpbGetClientIdResp,
        SET_CLIENT_ID_REQUEST   =>  nil,
        GET_SERVER_INFO_REQUEST =>  Riak::RpbGetServerInfoResp,
        GET_REQUEST             =>  Riak::RpbGetResp,
        PUT_REQUEST             =>  Riak::RpbPutResp,
        DEL_REQUEST             =>  nil,
        LIST_BUCKETS_REQUEST    =>  Riak::RpbListBucketsResp,
        LIST_KEYS_REQUEST       =>  Riak::RpbListKeysResp,
        GET_BUCKET_REQUEST      =>  Riak::RpbGetBucketResp,
        SET_BUCKET_REQUEST      =>  nil,
        MAP_REDUCE_REQUEST      =>  Riak::RpbMapRedResp
      }
    end
  end
end