#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the Accounts resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'
require 'connection_manager'
require 'erb'

include Connection_Manager

SAMPLE_ACCOUNT_KEY = 'A00001115'

class Account_Manager
  
  def initialize(z_client)
    @z_client = z_client
  end

  # Get Account Summary
  def get_summary(account_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::GET_ACCOUNT_SUMMARY.gsub('{account-key}', ERB::Util.url_encode(account_key))

    puts "========== GET ACCOUNT SUMMARY ============"
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

  # Get Account Details
  def get_details(account_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::GET_ACCOUNT_DETAIL.gsub('{account-key}', ERB::Util.url_encode(account_key))

    puts "========== GET ACCOUNT DETAILS ============"

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


  # create an account
  def create
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::POST_ACCOUNT

    args.req_body = ZAPIArgs.new
    args.req_body.name = 'Soho'
    args.req_body.currency = 'USD'
    args.req_body.notes = 'Soho Networks'
    args.req_body.billCycleDay = '15'
    args.req_body.paymentTerm = 'Net 30'
    args.req_body.dfadsf__c = "willie"
    args.req_body.billToContact = ZAPIArgs.new
    args.req_body.billToContact.address1 = 'address1'
    args.req_body.billToContact.address2 = 'address2'
    args.req_body.billToContact.city = 'San Francisco'
    args.req_body.billToContact.state = 'California'
    args.req_body.billToContact.country = 'USA'
    args.req_body.billToContact.firstName = 'John'
    args.req_body.billToContact.lastName = 'Doe'
    args.req_body.billToContact.mobilePhone = '14156789012'
    args.req_body.billToContact.workEmail = 'john.doe@zoura.com'

    args.req_body.soldToContact = ZAPIArgs.new
    args.req_body.soldToContact.address1 = 'address1'
    args.req_body.soldToContact.address2 = 'address2'
    args.req_body.soldToContact.city = 'San Francisco'
    args.req_body.soldToContact.country = 'USA'
    args.req_body.soldToContact.firstName = 'Jane'
    args.req_body.soldToContact.lastName = 'Doe'
    args.req_body.soldToContact.mobilePhone = '14156789012'
    args.req_body.soldToContact.state = 'California'
    args.req_body.soldToContact.workEmail = 'jane.doe@zoura.com'

    args.req_body.creditCard = ZAPIArgs.new
    args.req_body.creditCard.cardType = 'Visa'
    args.req_body.creditCard.cardNumber = '4856200223544175'
    args.req_body.creditCard.expirationMonth = 2
    args.req_body.creditCard.expirationYear = 2014
    args.req_body.creditCard.securityCode = '111'

    puts "========== CREATE AN ACCOUNT ============"

    begin
      @z_client.post(args) do |resp|
        ap resp
         return resp.accountNumber if resp.httpStatusCode.to_i == 200 && resp.success
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end
    
    nil
  end

  # Update an Account
  def update(account_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::PUT_ACCOUNT.gsub("{account-key}", ERB::Util.url_encode(account_key))

    args.req_body = ZAPIArgs.new
    args.req_body.billToContact = ZAPIArgs.new
    args.req_body.billToContact.homePhone = '9259259259'
    args.req_body.billToContact.zipCode = '94549'

    puts "========== UPDATE AN ACCOUNT ============"

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

  # Create an Account with subscription in one go
  def create_with_subscription
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::POST_ACCOUNT

    args.req_body = ZAPIArgs.new
    args.req_body.name = 'Soho'
    args.req_body.currency = 'USD'
    args.req_body.notes = 'Soho Networks'
    args.req_body.billCycleDay = '15'
    args.req_body.paymentTerm = 'Net 30'
    args.req_body.dfadsf__c = "willie"
    args.req_body.billToContact = ZAPIArgs.new
    args.req_body.billToContact.address1 = 'address1'
    args.req_body.billToContact.address2 = 'address2'
    args.req_body.billToContact.city = 'San Francisco'
    args.req_body.billToContact.state = 'California'
    args.req_body.billToContact.country = 'USA'
    args.req_body.billToContact.firstName = 'Jane'
    args.req_body.billToContact.lastName = 'Doe'
    args.req_body.billToContact.mobilePhone = '14156789012'
    args.req_body.billToContact.workEmail = 'jane.doe@zoura.com'

    args.req_body.soldToContact = ZAPIArgs.new
    args.req_body.soldToContact.address1 = 'address1'
    args.req_body.soldToContact.address2 = 'address2'
    args.req_body.soldToContact.city = 'San Francisco'
    args.req_body.soldToContact.country = 'USA'
    args.req_body.soldToContact.firstName = 'John'
    args.req_body.soldToContact.lastName = 'Doe'
    args.req_body.soldToContact.mobilePhone = '14156789012'
    args.req_body.soldToContact.state = 'California'
    args.req_body.soldToContact.workEmail = 'john.doe@zoura.com'

    args.req_body.creditCard = ZAPIArgs.new
    args.req_body.creditCard.cardType = 'Visa'
    args.req_body.creditCard.cardNumber = '4856200223544175'
    args.req_body.creditCard.expirationMonth = 2
    args.req_body.creditCard.expirationYear = 2014
    args.req_body.creditCard.securityCode = '111'

    args.req_body.subscription = ZAPIArgs.new
    args.req_body.subscription.contractEffectiveDate = '2013-02-1'
    args.req_body.subscription.termType = 'TERMED'
    args.req_body.subscription.initialTerm = '12'
    args.req_body.subscription.autoRenew = true
    args.req_body.subscription.renewalTerm = "3"
    args.req_body.subscription.subscribeToRatePlans = []
    args.req_body.subscription.subscribeToRatePlans[0] = ZAPIArgs.new
    args.req_body.subscription.subscribeToRatePlans[0].productRatePlanId = '4028e48735bd88440135c007d07e3169'
    args.req_body.subscription.subscribeToRatePlans[0].chargeOverrides = []
    args.req_body.subscription.subscribeToRatePlans[0].chargeOverrides[0] = ZAPIArgs.new
    args.req_body.subscription.subscribeToRatePlans[0].chargeOverrides[0].productRatePlanChargeId =
      '4028e48835a944f50135c00862171ab3'
    args.req_body.subscription.subscribeToRatePlans[0].chargeOverrides[0].quantity = 10
    args.req_body.invoiceTargetDate = "2013-12-31"
    args.req_body.invoiceCollect = true;

    puts "========== CREATE AN ACCOUNT WITH SUBSCRIPTION ============"

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

  # create an account resource manager
  @account_manager = Account_Manager.new(z_client)

  # Connect to the End Point using default tenant's credentials
  # and practice APIs
  if connected?(z_client)
    @account_manager.get_summary(SAMPLE_ACCOUNT_KEY)
    @account_manager.get_details(SAMPLE_ACCOUNT_KEY)
    account_number = @account_manager.create
    @account_manager.update(account_number) if account_number
    @account_manager.create_with_subscription
  end
end
