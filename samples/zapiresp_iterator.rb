#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to iterate on a complex ZAPIResp object
#

require 'rubygems'
require 'z_ruby_sdk'
require 'catalog_manager'
require 'connection_manager'

include Connection_Manager

def iterate_zapiresp(resp)
  # iterate the entire response set based on ZAPIResp
  # Refer to the API references for the response structure

  # get all products
  products = resp.products

  # for each product
  products.each {|p|

    # display some attributes
    ap p.sku
    ap p.name
    ap p.description

    # display custom fields
    ap p.P_Winnie__c
    ap p.P_Willie__c

    # get all product rate plans
    prps = p.productRatePlans

    # for each product rate plan
    prps.each {|prp|

      # display some attributes
      ap prp.id
      ap prp.status
      ap prp.name
      ap prp.description
      ap prp.effectiveStartDate
      ap prp.effectiveEndDate

      # display custom fields
      ap prp.PRP_Winnie__c
      ap prp.PRP_Willie__c

      # get all product rate plan charge summaries
      prp_charge_summaries = prp.productRatePlanCharges

      # for each charge summary
      prp_charge_summaries.each {|charge_summary|

        # display some attributes
        ap charge_summary.id
        ap charge_summary.name
        ap charge_summary.type
        ap charge_summary.model

        # Get all pricing summaries
        pricing_summary = charge_summary.pricingSummary

        # display every summary
        pricing_summary.each {|price_summary|
          ap price_summary
        }

        # display more charge summary attributes
        ap charge_summary.billingDay
        ap charge_summary.billingPeriod
        ap charge_summary.taxable
        ap charge_summary.taxCode
        ap charge_summary.taxMode
      }
    }

    # display next page link unless it is nil
    ap p.nextPage unless p.nextPage == nil
  }
end

# Create a z_client
z_client = Z_Client.new

# Create a Catalog resource object with a z_client
@catalog_manager = Catalog_Manager.new(z_client)

# Connect to the End Point using default tenant's credentials
# and practice APIs
if connected?(z_client)
  resp = @catalog_manager.get_products

  # follow nextPage if present
  while resp != nil
    # iterate on the response programmatically
    iterate_zapiresp(resp)
    if resp.nextPage.nil?
      resp = nil
    else
      resp = @catalog_manager.get_products(resp.nextPage)
    end
  end
end