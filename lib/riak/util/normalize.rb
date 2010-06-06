# Copyright 2010 Sean Cribbs, Sonian Inc., and Basho Technologies, Inc.
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
require 'riak'

module Riak
  module Util

    module Normalize

      # Normalize a list of walk specs into WalkSpec objects.
      def normalize(*params)
        params.flatten!
        specs = []
        while params.length > 0
          param = params.shift
          case param
          when Hash
            specs << new(param)
          when WalkSpec
            specs << param
          else
            if params.length >= 2
              specs << new(param, params.shift, params.shift)
            else
              raise ArgumentError, t("too_few_arguments", :params => params.inspect)
            end
          end
        end
        specs
      end

    end # module Decode
  end
end

