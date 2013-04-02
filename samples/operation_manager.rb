#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the Operations resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'
require 'connection_manager'

include Connection_Manager

SAMPLE_ACCOUNT_KEY = 'A00001115'

class Operation_Manager

  def initialize(z_client)
    @z_client = z_client
  end

  # invoice and collect payment from and account
  def create_billrun(account_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::POST_INVOICE_COLLECT

    args.req_body = ZAPIArgs.new
    args.req_body.accountKey = account_key
    args.req_body.invoiceTargetDate = '2013-3-31'

    puts "========== CREATE ACCOUNT BILL RUN ==========="

    begin
      @z_client.post(args) do |resp|
        ap resp
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end
  end

end

# execute only if invoked directly
if __FILE__ == $0
  # Create a z_client
  z_client = Z_Client.new

  # Create a z_client object and pass it to APIRepo
  @operation_manager = Operation_Manager.new(z_client)

  # Connect to the End Point using default tenant's credentials
  # and practice APIs
  @operation_manager.create_billrun(SAMPLE_ACCOUNT_KEY) if connected?(z_client)
end