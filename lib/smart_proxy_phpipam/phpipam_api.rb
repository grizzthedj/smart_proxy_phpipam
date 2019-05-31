require 'sinatra'
require 'smart_proxy_phpipam/phpipam'
require 'smart_proxy_phpipam/phpipam_main'
require 'smart_proxy_phpipam/phpipam_client'

module Proxy::Phpipam
  class Api < ::Sinatra::Base
    include ::Proxy::Log
    helpers ::Proxy::Helpers

    get '/next_ip' do
      content_type :json

      begin
        cidr = params[:cidr]
        
        if not cidr
          return {error: "A 'cidr' parameter for the subnet must be provided(e.g. 100.10.10.0/24)"}.to_json
        end

        response = PhpipamClient.get_subnet(cidr)

        if response['message'] && response['message'].downcase == "no subnets found"
          return {error: "The specified subnet does not exist in phpIPAM."}.to_json
        end
  
        subnet_id = response['data'][0]['id']
        response = PhpipamClient.get_next_ip(subnet_id)

        if response['message'] && response['message'].downcase == "no free addresses found"
          return {error: "There are no more free addresses in subnet #{cidr}"}.to_json
        end

        {cidr: cidr, next_ip: response['data']}.to_json
      rescue Errno::ECONNREFUSED => e
        return {error: "Unable to connect to phpIPAM server"}.to_json
      end
    end

    get '/get_subnet' do
      content_type :json

      begin
        cidr = params[:cidr]

        subnet = PhpipamClient.get_subnet(cidr)
        subnet.to_json
      rescue Errno::ECONNREFUSED => e
        return {error: "Unable to connect to phpIPAM server"}.to_json
      end
    end

    get '/sections' do
      content_type :json

      begin
        sections = PhpipamClient.get_sections
        sections.to_json
      rescue Errno::ECONNREFUSED => e
        return {error: "Unable to connect to phpIPAM server"}.to_json
      end
    end

    get '/sections/:section_id/subnets' do
      content_type :json 

      begin
        section_id = params[:section_id]
        
        if not section_id
          return {error: "A 'section_id' must be provided"}.to_json
        end

        subnets = PhpipamClient.get_subnets(section_id)
        subnets.to_json
      rescue Errno::ECONNREFUSED => e
        return {error: "Unable to connect to phpIPAM server"}.to_json
      end
    end

    get '/ip_exists' do
      content_type :json 

      begin
        cidr = params[:cidr]
        ip = params[:ip]

        return {error: "Missing 'cidr' parameter. A CIDR IPv4 address must be provided(e.g. 100.10.10.0/24)"}.to_json if not cidr
        return {error: "Missing 'ip' parameter. An IPv4 address must be provided(e.g. 100.10.10.22)"}.to_json if not ip

        response = PhpipamClient.get_subnet(cidr)

        if response['message'] && response['message'].downcase == "no subnets found"
          return {error: "The specified subnet does not exist in phpIPAM."}.to_json
        end

        subnet_id = response['data'][0]['id']

        response = PhpipamClient.ip_exists(ip, subnet_id)

        if response && response['message'] && response['message'].downcase == 'no addresses found'
          exists = {ip: ip, exists: false}
        else 
          exists = {ip: ip, exists: true}
        end

        exists.to_json
      rescue Errno::ECONNREFUSED => e
        return {error: "Unable to connect to phpIPAM server"}.to_json
      end
    end

    post '/add_ip_to_subnet' do
      content_type :json

      begin
        cidr = params[:cidr]
        ip = params[:ip]

        return {error: "Missing 'cidr' parameter. A CIDR IPv4 address must be provided(e.g. 100.10.10.0/24)"}.to_json if not cidr
        return {error: "Missing 'ip' parameter. An IPv4 address must be provided(e.g. 100.10.10.22)"}.to_json if not ip

        response = PhpipamClient.get_subnet(cidr)

        if response['message'] && response['message'].downcase == "no subnets found"
          return {error: "The specified subnet does not exist in phpIPAM."}.to_json
        end

        subnet_id = response['data'][0]['id']

        PhpipamClient.add_ip_to_subnet(ip, subnet_id, 'Address auto added by Foreman')

        {message: "IP #{ip} added to subnet #{cidr} successfully."}.to_json
      rescue Errno::ECONNREFUSED => e
        return {error: "Unable to connect to phpIPAM server"}.to_json
      end
    end

    post '/delete_ip_from_subnet' do
      content_type :json

      begin
        cidr = params[:cidr]
        ip = params[:ip]

        return {error: "Missing 'cidr' parameter. A CIDR IPv4 address must be provided(e.g. 100.10.10.0/24)"}.to_json if not cidr
        return {error: "Missing 'ip' parameter. An IPv4 address must be provided(e.g. 100.10.10.22)"}.to_json if not ip

        response = PhpipamClient.get_subnet(cidr)

        if response['message'] && response['message'].downcase == "no subnets found"
          return {error: "The specified subnet does not exist in phpIPAM."}.to_json
        end

        subnet_id = response['data'][0]['id']

        PhpipamClient.delete_ip_from_subnet(ip, subnet_id)

        {message: "IP #{ip} deleted from subnet #{cidr} successfully."}.to_json
      rescue Errno::ECONNREFUSED => e
        return {error: "Unable to connect to phpIPAM server"}.to_json
      end
    end

  end
end
