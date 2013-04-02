#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the Catalog resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'
require 'connection_manager'

include Connection_Manager

class Catalog_Manager

  def initialize(z_client)
    @z_client = z_client
  end

  # Get products in a catalog
  def get_products(next_page=nil)
    args = ZAPIArgs.new

    # if next
    if next_page
      args.uri = next_page
    else
      args.uri = Resource_Endpoints::GET_PRODUCT_CATALOG
      args.query_string = ZAPIArgs.new
      args.query_string.pageSize = 10
    end

    puts "========== GET PRODUCT CATALOG ============"

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

# execute only if invoked directly, not 'require'
if __FILE__ == $0
  # Create a z_client
  z_client = Z_Client.new

  # Create a Catalog resource object with a z_client
  @catalog_manager = Catalog_Manager.new(z_client)

  # Connect to the End Point using default tenant's credentials
  # and practice APIs
  if connected?(z_client)
    resp = @catalog_manager.get_products
  end

  # follow nextPage if present
  while resp != nil
    if resp.nextPage.nil?
      resp = nil
    else
      resp = @catalog_manager.get_products(resp.nextPage)
    end
  end
end