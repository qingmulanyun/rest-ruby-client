#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the Transactions resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'
require 'connection_manager'
require 'erb'

include Connection_Manager

SAMPLE_ACCOUNT_KEY = 'A00001115'

class Transaction_Manager

  def initialize(z_client)
    @z_client = z_client
  end

  # Get Invoices
  def get_invoices(account_key, next_page=nil)
    args = ZAPIArgs.new

    if next_page
      args.uri = next_page
    else
      args.uri = Resource_Endpoints::GET_INVOICES.gsub('{account-key}', ERB::Util.url_encode(account_key))
      args.query_string = ZAPIArgs.new
      args.query_string.pageSize = 10
    end

    puts "========== GET INVOICES ============"

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

  # Get Payments
  def get_payments(account_key, next_page=nil)
    args = ZAPIArgs.new

    if next_page
      args.uri = next_page
    else
      args.uri = Resource_Endpoints::GET_PAYMENTS.gsub('{account-key}', ERB::Util.url_encode(account_key))
      args.query_string = ZAPIArgs.new
      args.query_string.pageSize = 10
    end

    puts "========== GET PAYMENTS ============"

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
end

# execute only if invoked directly
if __FILE__ == $0
  # create a Z_Client
  z_client = Z_Client.new

  # Create a z_client object and pass it to APIRepo
  @transaction_manager = Transaction_Manager.new(z_client)

  # Connect to the End Point using default tenant's credentials
  # and practice APIs
  if connected?(z_client)
    resp = @transaction_manager.get_invoices(SAMPLE_ACCOUNT_KEY)

    # follow nextPage if present
    while resp != nil
      if resp.nextPage.nil?
        resp = nil
      else
        resp = @transaction_manager.get_invoices(SAMPLE_ACCOUNT_KEY, resp.nextPage)
      end
    end

    resp = @transaction_manager.get_payments(SAMPLE_ACCOUNT_KEY)

    # follow nextPage if present
    while resp != nil
      if resp.nextPage.nil?
        resp = nil
      else
        resp = @transaction_manager.get_payments(SAMPLE_ACCOUNT_KEY, resp.nextPage)
      end
    end
  end
end