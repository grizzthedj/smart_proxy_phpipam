
module Proxy::Phpipam
  extend ::Proxy::Util
  extend ::Proxy::Log

  class << self
    def get_config
      Proxy::Phpipam::Plugin.settings.phpipam
    end
  end
end
