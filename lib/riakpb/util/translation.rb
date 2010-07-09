require 'riakpb'

module Riakpb
  module Util
    module Translation
      def i18n_scope
        :riak
      end

      def t(message, options={})
        I18n.t("#{i18n_scope}.#{message}", options)
      end
    end
  end
end

