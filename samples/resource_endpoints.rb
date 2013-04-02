#
# Copyright (c) 2013 Zuora Inc.
#
# Sample code to demonstrate how to define all available resource endpoints
#

module Resource_Endpoints

  # CONNECTIONS API RESOURCES
  CONNECT = '/connections'

  # CATALOG API RESOURCES
  GET_PRODUCT_CATALOG = '/catalog/products'

  # ACCOUNTS API RESOURCES
  GET_ACCOUNT_DETAIL = '/accounts/{account-key}'
  GET_ACCOUNT_SUMMARY = '/accounts/{account-key}/summary'
  POST_ACCOUNT = '/accounts'
  PUT_ACCOUNT = '/accounts/{account-key}'

  # PAYMENT METHODS API RESOURCES
  GET_CREDIT_CARDS = '/payment-methods/credit-cards/accounts/{account-key}'
  POST_CREDIT_CARD = '/payment-methods/credit-cards'
  PUT_CREDIT_CARD = '/payment-methods/credit-cards/{payment-method-id}'
  DELETE_PAYMENT_METHOD = '/payment-methods/{payment-method-id}'

  # TRANSACTIONS API RESOURCES
  GET_INVOICES = '/transactions/invoices/accounts/{account-key}'
  GET_PAYMENTS = '/transactions/payments/accounts/{account-key}'
  GET_USAGE = '/usage/accounts/{account-key}'

  # SUBSCRIPTIONS API RESOURCES
  GET_SUBSCRIPTION = '/subscriptions/{subscription-key}'
  GET_SUBSCRIPTIONS = '/subscriptions/accounts/{account-key}'
  POST_SUBSCRIPTION = '/subscriptions'
  POST_SUBSCRIPTION_PREVIEW = '/subscriptions/preview'
  PUT_SUBSCRIPTION = '/subscriptions/{subscription-key}'
  PUT_SUBSCRIPTION_RENEW = '/subscriptions/{subscription-key}/renew'
  PUT_SUBSCRIPTION_CANCEL = '/subscriptions/{subscription-key}/cancel'

  # OPERATIONS API RESOURCES
  POST_INVOICE_COLLECT = '/operations/invoice-collect'

  # USAGE API RESOURCES
  POST_USAGE = '/usage'
  
end