#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to use the PaymentMethods resources
#

require 'rubygems'
require 'resource_endpoints'
require 'z_ruby_sdk'
require 'connection_manager'
require 'erb'

include Connection_Manager

SAMPLE_ACCOUNT_KEY = 'A00001115'

class Payment_Method_Manager

  def initialize(z_client)
    @z_client = z_client
  end

  # Get Credit Cards
  def get_credit_cards(account_key, next_page=nil)
    args = ZAPIArgs.new
    
    if next_page
      # temporary monkey patch for backend ...
      args.uri = next_page
    else
      args.uri = Resource_Endpoints::GET_CREDIT_CARDS.gsub('{account-key}', ERB::Util.url_encode(account_key))
      args.query_string = ZAPIArgs.new
      args.query_string.pageSize = 2
    end

    puts "========== GET CREDIT CARDS ============"

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

  # create a credit card then delete it
  def create_credit_card(account_key)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::POST_CREDIT_CARD

    args.req_body = ZAPIArgs.new
    args.req_body.accountKey = account_key
    args.req_body.creditCardType = 'Visa'
    args.req_body.creditCardNumber = '4856200223544175'
    args.req_body.expirationMonth = '10'
    args.req_body.expirationYear = '2015'
    args.req_body.securityCode = '111'
    args.req_body.defaultPaymentMethod = false
    args.req_body.cardHolderInfo = ZAPIArgs.new
    args.req_body.cardHolderInfo.cardHolderName = "Tien Zou"
    args.req_body.cardHolderInfo.addressLine1 = "7 Faxon Forest"
    args.req_body.cardHolderInfo.addressLine2 = ""
    args.req_body.cardHolderInfo.city = "Artherton"
    args.req_body.cardHolderInfo.state = "California"
    args.req_body.cardHolderInfo.zipCode = "94029"
    args.req_body.cardHolderInfo.country = "USA"
    args.req_body.cardHolderInfo.phone = "4152345678"
    args.req_body.cardHolderInfo.email = "chief@subscription.com"

    puts "========== CREATE AN CREDIT CARD ============"

    begin
      @z_client.post(args) do |resp|
        ap resp
        return resp.paymentMethodId if resp.httpStatusCode.to_i == 200 && resp.success
      end
    rescue ArgumentError => e
      puts e.message
    rescue RuntimeError => e
      puts e.message
    end
    
    nil
  end

  # Update Credit Card
  def update_credit_card(payment_method_id)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::PUT_CREDIT_CARD.gsub("{payment-method-id}", payment_method_id)

    args.req_body = ZAPIArgs.new
    args.req_body.expirationMonth = 8
    args.req_body.expirationYear = 2015
    args.req_body.securityCode = '111'
    args.req_body.cardHolderName = 'Leo'

    puts "========== UPDATE A CREDIT CARD ============"

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

  # Delete Payment Method#
  def delete_credit_card(payment_method_id)
    args = ZAPIArgs.new
    args.uri = Resource_Endpoints::DELETE_PAYMENT_METHOD.gsub("{payment-method-id}", payment_method_id)

    puts "========== DELETE A PAYMENT METHOD ============"

    begin
      @z_client.delete(args) do |resp|
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
  # create a z_client
  z_client = Z_Client.new

  # Create a Catalog resource object with a z_client
  @payment_method_manager = Payment_Method_Manager.new(z_client)

  # Connect to the End Point using default tenant's credentials
  # and practice APIs
  if connected?(z_client)
    resp = @payment_method_manager.get_credit_cards(SAMPLE_ACCOUNT_KEY)
  end

  # follow nextPage if present
  while resp != nil
    if resp.nextPage.nil?
      resp = nil
    else
      resp = @payment_method_manager.get_credit_cards(SAMPLE_ACCOUNT_KEY, resp.nextPage)
    end
  end

  payment_method_id = @payment_method_manager.create_credit_card(SAMPLE_ACCOUNT_KEY)
  if payment_method_id
    @payment_method_manager.update_credit_card(payment_method_id)
    @payment_method_manager.delete_credit_card(payment_method_id)
  end
end