require 'test_helper'
require 'webmock/test_unit'
require 'mocha/test_unit'
require 'rack/test'

require 'smart_proxy_phpipam/phpipam'
require 'smart_proxy_phpipam/phpipam_api'

class PhpipamApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Proxy::Phpipam::Api.new
  end

  def test_returns_hello_greeting
    # add test here
  end

end
