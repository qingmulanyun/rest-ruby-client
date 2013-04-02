#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to program a multi-threaded application
#

require 'rubygems'
require 'z_ruby_sdk'
require 'catalog_manager'
require 'connection_manager'

include Connection_Manager

threads = []

# 5 parallel threads running get_products
5.times {|i|
  threads << Thread.new do
    # Create a z_client
    z_client = Z_Client.new

    # Create a Catalog resource object with a z_client
    @catalog_manager = Catalog_Manager.new(z_client)

    # Connect to the End Point using default tenant's credentials
    # and practice APIs
    resp = @catalog_manager.get_products if connected?(z_client)

    # follow nextPage if present
    while resp != nil
      if resp.nextPage.nil?
        resp = nil
      else
        resp = @catalog_manager.get_products(resp.nextPage)
      end
    end
  end
}

# exit after all finished
threads.each {|t|
  t.join
}