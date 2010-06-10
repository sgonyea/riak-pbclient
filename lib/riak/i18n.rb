begin
  require 'active_support/i18n'
rescue LoadError
  require 'i18n' # support ActiveSupport < 3
end

I18n.load_path << File.expand_path("../locale/en.yml", __FILE__)
