
require 'smart_proxy_phpipam/phpipam_api'

map '/phpipam' do
  run Proxy::Phpipam::Api
end
