#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the Usage resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'
require 'connection_manager'
require 'erb'

include Connection_Manager

SAMPLE_ACCOUNT_KEY = 'A00001115'
SAMPLE_USAGE_FILE = "/home/user/NetBeansProjects/zuora.rest.ruby/samples/sample_usage.csv"
SAMPLE_WAIT = 15

class Usage_Manager
  
  def initialize(z_client)
    @z_client = z_client
  end

  # Get Usage
  def get(account_key, next_page=nil)
    args = ZAPIArgs.new

    if next_page
      args.uri = next_page
    else
      args.uri = Resource_Endpoints::GET_USAGE.gsub('{account-key}', ERB::Util.url_encode(account_key))
      args.query_string = ZAPIArgs.new
      args.query_string.pageSize = 10
    end

    puts "========== GET USAGE ============"

    response = nil
    begin
      @z_client.get(args) do |resp|
        ap resp
        if resp.httpStatusCode.to_i == 200 && resp.success
          response = resp
        end
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end

    response
  end

  # Upload a zipped usage file
  def create(fully_qualified_filename)
    puts "========== UPLOAD A USAGE FILE ============"

    # Reject if file not found
    unless File.exists?(fully_qualified_filename)
      puts "Failed to upload usage file #{fully_qualified_filename}. File not found."
      return
    end

    # Reject if wrong file type
    if ([".xls", ".csv", ".zip"].detect {|ext| ext == File.extname(fully_qualified_filename).downcase}).nil?
      puts "Failed to upload usage file #{fully_qualified_filename}."
      puts "File extension not supported. Must be .csv, .xls, or .zip"
      return
    end

    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::POST_USAGE

    args.req_body = ZAPIArgs.new
    args.req_body.filename = fully_qualified_filename
    
    response = nil
    begin
      @z_client.post(args) do |resp|
        ap resp
        response = resp
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end

    # if response is there, is http good, is Zuora good, and checkInmportStatus returned
    if response && response.httpStatusCode.to_i == 200 && response.success && response.checkImportStatus
      
      # hang in there a bit and see if import actually worked
      sleep SAMPLE_WAIT
      args = ZAPIArgs.new
      args.uri = response.checkImportStatus

      puts "========== GET IMPORT STATUS ============"
      begin
       @z_client.get(args) do |resp|
          ap resp
        end
      rescue ArgumentError => e
        puts e.message
      rescue RuntimeError => e
        puts e.message
      end
    end
  end

end

# execute only if invoked directly
if __FILE__ == $0
  # Create a Z_Client object
  z_client = Z_Client.new

  # Create a z_client object and pass it to APIRepo
  @usage_manager = Usage_Manager.new(z_client)

  # Connect to the End Point using default tenant's credentials
  # and practice APIs
  if connected?(z_client)
    @usage_manager.create(SAMPLE_USAGE_FILE)
    resp = @usage_manager.get(SAMPLE_ACCOUNT_KEY)

    # follow nextPage if present
    while resp != nil
      if resp.nextPage.nil?
        resp = nil
      else
        resp = @usage_manager.get(SAMPLE_ACCOUNT_KEY, resp.nextPage)
      end
    end
  end
end
