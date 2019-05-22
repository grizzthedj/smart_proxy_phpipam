
require 'yaml'
require 'logger'
require 'json' 
require 'net/http'
require 'smart_proxy_phpipam/phpipam'
require 'smart_proxy_phpipam/phpipam_main'

module Proxy::Phpipam
  class PhpipamClient  
    conf = Proxy::Phpipam.get_config
    @phpipam_config = {url: conf[:url], user: conf[:user], password: conf[:password]}
    @api_base = conf[:url] + '/api/' + conf[:user] + '/'
    @token = nil

    def self.get_subnet(cidr)
      url = 'subnets/cidr/' + cidr.to_s + '/'
      self.get(url) 
    end

    def self.get_next_ip(subnet_id)
      url = 'subnets/' + subnet_id.to_s + '/first_free/'
      self.get(url)
    end

    def self.add_ip_to_subnet(ip, subnet_id, desc)
      data = {'subnetId': subnet_id, 'ip': ip, 'description': desc}
      self.post('addresses/', data) 
    end

    def self.get_sections
      self.get('sections/')['data']
    end

    def self.get_subnets(section_id)
      self.get('sections/' + section_id.to_s + '/subnets/')
    end

    def self.ip_exists(ip, subnet_id)
      self.get('subnets/' + subnet_id.to_s + '/addresses/' + ip + '/')
    end

    private

    def self.get(path, body=nil)
      self.authenticate
      uri = URI(@api_base + path)
      uri.query = URI.encode_www_form(body) if body
      request = Net::HTTP::Get.new(uri)
      request['token'] = @token

      response = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(request)
      }

      JSON.parse(response.body)
    end

    def self.post(path, body=nil)
      self.authenticate
      uri = URI(@api_base + path)
      uri.query = URI.encode_www_form(body) if body
      request = Net::HTTP::Post.new(uri)
      request['token'] = @token

      response = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(request)
      }

      JSON.parse(response.body)
    end

    def self.authenticate
      if @token == nil
        auth_uri = URI(@api_base + '/user/')
        request = Net::HTTP::Post.new(auth_uri)
        request.basic_auth @phpipam_config[:user], @phpipam_config[:password]

        response = Net::HTTP.start(auth_uri.hostname, auth_uri.port) {|http|
          http.request(request)
        }

        response = JSON.parse(response.body)
        @token = response['data']['token']
      end
    end
  end
end