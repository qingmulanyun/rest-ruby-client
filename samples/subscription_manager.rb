#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the Subscriptions resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'
require 'connection_manager'
require 'erb'

include Connection_Manager

SAMPLE_ACCOUNT_KEY = 'A00001115'

class Subscription_Manager

  def initialize(z_client)
    @z_client = z_client
  end

  # Get subscriptions by account
  def get_all(account_key, next_page=nil)
    args = ZAPIArgs.new

    if next_page
      args.uri = next_page
    else
      args.uri = Resource_Endpoints::GET_SUBSCRIPTIONS.gsub('{account-key}', ERB::Util.url_encode(account_key))
      args.query_string = ZAPIArgs.new
      args.query_string.pageSize = 10
    end

    puts "========== GET SUBSCRIPTIONS ============"

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
  
  # Create a subscription without an account and for preview only
  def create_preview
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::POST_SUBSCRIPTION_PREVIEW

    args.req_body = ZAPIArgs.new

    args.req_body.termType = "TERMED"
    args.req_body.initialTerm = 12
    args.req_body.contractEffectiveDate = "2013-1-15"
    args.req_body.invoiceTargetDate = '2013-12-31'

    args.req_body.previewAccountInfo = ZAPIArgs.new
    args.req_body.previewAccountInfo.currency = 'USD'
    args.req_body.previewAccountInfo.billCycleDay = 31
    args.req_body.previewAccountInfo.billToContact = ZAPIArgs.new
    args.req_body.previewAccountInfo.billToContact.city = 'Walnut Creek'
    args.req_body.previewAccountInfo.billToContact.county = 'Contra Consta'
    args.req_body.previewAccountInfo.billToContact.state = 'California'
    args.req_body.previewAccountInfo.billToContact.zipCode = '94549'
    args.req_body.previewAccountInfo.billToContact.country = 'United States'

    args.req_body.subscribeToRatePlans = []
    args.req_body.subscribeToRatePlans[0] = ZAPIArgs.new
    args.req_body.subscribeToRatePlans[0].productRatePlanId = 'ff8080811ca15d19011cdda9b0ad3b51'
    args.req_body.subscribeToRatePlans[0].chargeOverrides = []
    args.req_body.subscribeToRatePlans[0].chargeOverrides[0] = ZAPIArgs.new
    args.req_body.subscribeToRatePlans[0].chargeOverrides[0].productRatePlanChargeId =
      'ff8080811ca15d19011cddad8c953b53'
    args.req_body.subscribeToRatePlans[0].chargeOverrides[0].quantity = 100

    puts "========== CREATE A SUBSCRIPTION FOR PREVIEW ============"

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

  # create a subscription with an existing account
  def create
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::POST_SUBSCRIPTION

    args.req_body = ZAPIArgs.new
    args.req_body.accountKey = SAMPLE_ACCOUNT_KEY
    args.req_body.contractEffectiveDate = '2013-02-1'
    args.req_body.termType = 'TERMED'
    args.req_body.initialTerm = '12'
    args.req_body.autoRenew = true
    args.req_body.renewalTerm = "3"
    args.req_body.notes = 'Test POST subscription from z-ruby-sdk'
    args.req_body.subscribeToRatePlans = []
    args.req_body.subscribeToRatePlans[0] = ZAPIArgs.new
    args.req_body.subscribeToRatePlans[0].productRatePlanId = 'ff8080811ca15d19011cdda9b0ad3b51'
    args.req_body.subscribeToRatePlans[0].chargeOverrides = []
    args.req_body.subscribeToRatePlans[0].chargeOverrides[0] = ZAPIArgs.new
    args.req_body.subscribeToRatePlans[0].chargeOverrides[0].productRatePlanChargeId =
      'ff8080811ca15d19011cddad8c953b53'
    args.req_body.subscribeToRatePlans[0].chargeOverrides[0].quantity = 10
    args.req_body.invoiceTargetDate = '2013-12-31'
    args.req_body.invoiceCollect = false

    puts "========== CREATE A SUBSCRIPTION ============"

    begin
      @z_client.post(args) do |resp|
        ap resp
        return resp.subscriptionNumber if resp.httpStatusCode.to_i == 200 && resp.success
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end

    nil
  end

  # Get subscription by id
  def get(subscription_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::GET_SUBSCRIPTION.gsub("{subscription-key}", ERB::Util.url_encode(subscription_key))

    puts "========== GET A SUBSCRIPTION ============"

    begin
      @z_client.get(args) do |resp|
        ap resp
        return resp if resp.httpStatusCode.to_i == 200 && resp.success
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end

    nil
  end

  # Update a subscription
  def update(subscription_key, rate_plan_id, rate_plan_charge_id)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::PUT_SUBSCRIPTION.gsub("{subscription-key}", ERB::Util.url_encode(subscription_key))

    args.req_body = ZAPIArgs.new
    args.req_body.termType = 'TERMED'
    args.req_body.currentTerm = '10'
    args.req_body.autoRenew = false
    args.req_body.renewalTerm = "4"
    args.req_body.notes = 'Test UPDATE subscription from z-ruby-sdk'
    args.req_body.update = []
    args.req_body.update[0] = ZAPIArgs.new
    args.req_body.update[0].ratePlanId = rate_plan_id
    args.req_body.update[0].chargeUpdateDetails = []
    args.req_body.update[0].chargeUpdateDetails[0] = ZAPIArgs.new
    args.req_body.update[0].chargeUpdateDetails[0].ratePlanChargeId = rate_plan_charge_id
    args.req_body.update[0].chargeUpdateDetails[0].quantity = 12
    args.req_body.update[0].contractEffectiveDate = '2013-04-28'

    puts "========== UPDATE A SUBSCRIPTION ============"

    begin
      @z_client.put(args) do |resp|
        ap resp
     end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end
  end

  # Renew a subscription
  def renew(subscription_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::PUT_SUBSCRIPTION_RENEW.gsub("{subscription-key}", ERB::Util.url_encode(subscription_key))

    args.req_body = ZAPIArgs.new
    args.req_body.invoiceCollect = false

    puts "========== RENEW A SUBSCRIPTION ============"

    begin
      @z_client.put(args) do |resp|
        ap resp
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end
  end

  # Cancel a subscription
  def cancel(subscription_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::PUT_SUBSCRIPTION_CANCEL.gsub("{subscription-key}", ERB::Util.url_encode(subscription_key))

    args.req_body = ZAPIArgs.new
    args.req_body.cancellationPolicy = 'EndOfCurrentTerm'
    args.req_body.cancellationEffectiveDate = "2013-05-31"
    args.req_body.invoiceCollect = false

    puts "========== CANCEL A SUBSCRIPTION ============"

    begin
      @z_client.put(args) do |resp|
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
  # create a Z_Client
  z_client = Z_Client.new

  # Create a z_client object and pass it to APIRepo
  @subscription_manager = Subscription_Manager.new(z_client)

  # Connect to the End Point using default tenant's credentials
  # and practice APIs
  if connected?(z_client)
    resp = @subscription_manager.get_all(SAMPLE_ACCOUNT_KEY)
    
    # follow nextPage if present
    while resp != nil
      if resp.nextPage.nil?
        resp = nil
      else
        resp = @subscription_manager.get_all(SAMPLE_ACCOUNT_KEY, resp.nextPage)
      end
    end

    @subscription_manager.create_preview
    subscription_number = @subscription_manager.create
    if subscription_number
      resp = @subscription_manager.get(subscription_number)
      if resp
        @subscription_manager.update(resp.subscriptionNumber, resp.ratePlans[0].id, resp.ratePlans[0].ratePlanCharges[0].id)
        @subscription_manager.renew(resp.subscriptionNumber)
        @subscription_manager.cancel(resp.subscriptionNumber)
      end
    end
  end
end