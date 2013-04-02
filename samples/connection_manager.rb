#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the Connections resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'

module Connection_Manager

  def connected?(z_client, api_access_key_id=nil, api_secret_access_key=nil)
    @z_client = z_client

    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::CONNECT
    args.headers = ZAPIArgs.new
    args.headers.apiAccessKeyId = api_access_key_id
    args.headers.apiSecretAccessKey = api_secret_access_key

    puts "========== CONNECT SERVICE ENDPOINT ============"

    begin
      @z_client.post(args) do |resp|
        ap resp
        return true if resp.httpStatusCode.to_i == 200 && resp.success
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end

    nil
  end
  
end
