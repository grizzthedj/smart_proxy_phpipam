
module Proxy::Phpipam
  class NotFound < RuntimeError; end

  class Plugin < ::Proxy::Plugin
    plugin 'phpipam', Proxy::Phpipam::VERSION

    http_rackup_path File.expand_path('phpipam_http_config.ru', File.expand_path('../', __FILE__))
    https_rackup_path File.expand_path('phpipam_http_config.ru', File.expand_path('../', __FILE__))
  end
end
