Pre-requisites

    The following gems are required:

    httpclient, >= 2.3.1
    json_pure, >= 1.7.6
    hashie, >= 1.2.0
    awesome_print >= 1.1.0

    You also need a trial account in any Zuora application, go get a free trial 
    at http://info.zuora.com/zuora-free-trial.html and then 
    update `config/z_config.yml` with your credential.
    
Installation

    From github after download
       gem install --local z_ruby_sdk-1.0.gem

Version
    1.0

Description

    zuora-rest-ruby facilitates developers to build Ruby based
    Zuora applications without being burdened by the underlying HTTP mechanics,
    multi-threading, proxy, SSL security, error handling, and logging support
    required for debugging and troubleshooting. Complex JSON responses and call
    arguments can also be manipulated using simple ruby methods.

    The sample code demonstrates how all Zuora REST resources can be modeled
    as "resource manager". There are 8 resource manager classes: Connection,
    Catalog, Payment_Method, Account, Subscription, Transaction, Operation
    and Usage. Three sample usage files are also provided.

Features

    . Support MRI Ruby 1.8.7 or above

    . Support JRuby (no native code in the gem)

    . Environment agnostic. Support pure ruby script and Rails

    . Support configuration for local installation needs

    . Provide full API pre-call and post-call trace for easy debugging

    . Provide log files as support documentation

    . Support multi-threading environment with http connection pooling

    . Navigate call arguments and JSON response string using setter and getter

    . Support VERIFY NONE and VERIFY PEER for SSL invocations

    . Support proxy, including basic authentication

Configuration

    Support global configuration via z_config.yml located in the config
    subdirectory. This can be customized and used by the developers
    as the default configuration and further simply code.

    Different applications can also use different configuration. This is
    achieved by including a local copy of a z_config.properties in the working
    directory (i.e. pwd) where the application runs.

    Change Installation specific properties as needed. Most default settings
    work in most installations, but some are installation specific properties:

    . Setting default tenant's credentials enables a connect call to be made
      without arguments - remove security sensitive information from developers.

    . if using forwarding proxy server set proxy_used to true

    . If the proxy uses basic authentication set proxy_auth to true, and its
      credentials in proxy_user and proxy_password.

    . When developing switch on api trace for debugging. Set api_trace to true.

    . If you are worried about the authenticity of the api end point
      set ssl_verify to true. This may slightly degrade performance on CONNECT
      calls.

Logging

    SDK puts all log files in the subdirectory "sdk_logs" under the current
    working directory where the application runs.

    sdk.log is for the sdk itself.

    api_trace.log is for API debugging.

    When filing an incident report to Zuora, both logs should be sent as documentation.

    Each log files has a 4M size limit and up to 3 generations before it is
    wrapped around.

Examples

    Refer to the samples for the following discussion. You
    can write your own resource managers or any other abstraction; they are only
    there to illustrate one way of designing application objects around the
    APIs.

    1. require 'rubygems' 
       require 'z_ruby_sdk'

    2. All calls must be routed through Z_Client. To create a Z_Client:

            z_client = Z_Client.new

       Use the get, put, post, and delete methods to send a REST API.

    3. Pass the client object to the resource manager object.

    4. Prepare arguments

       All arguments are ultimately put inside a JSON structure. Some arguments,
       mandatory or optional, are required to be created in some nested structure.

       Use the ZAPIArgs class which allows argument object to be manipulated
       simply like attributes. Whenever there is a need for a nested
       argument structure, use new ZAPIArgs. Refer to sample code and the
       corresponding published call arguments in the API documentation
       for more sample usage.

       There are 4 key attributes in ZAPIArgs that are needed to make a REST
       API call:

       uri
        The resource uri (excluding the API endpoint). For instance
            args =  ZAPIArgs.new
            args.uri = "/catalog/products"

        Predefined resource endpoints are provided as samples and can be found
        in resource_endpoints.rb

       headers
        Used as fields in request header. Only relevant to CONNECT API
            args = ZAPIArgs.new
            args.headers = ZAPIArgs.new
            args.headers.apiAccessKeyID = "api_tester"
            args.headers.apiSecretAccessKey = "password"

        If a ZConfig.properties file has the default tenant's credentials
        configured, these headers will not be needed when connecting to
        the default tenant.


       query_string
        Also known as HTTP parameters. For instance
            args = ZAPIArgs.new
            args.query_string = ZAPIArgs.new
            args.query_string.pageSize = 20

       req_body
        Most POST and PUT APIs require substantial amount of arguments to be set
        up in the request body of the HTTP request. This needs to be set up
        before the request can be sent to the service provider.

            args = ZAPIArgs.new
            args.req_body = ZAPIArgs.new
            args.req_body.name = "api_tester"
            args.req_body.billToContact = ZAPIArgs.new
            args.req_body.billToContact.firstName = "api"
            args.req_body.billToContact.lastName = "Tester"

       Consult the Zuora REST API documentation for details of the call arguments.

    5. Authenticate to the endpoint using tenant's user id and password:

        connect()  # connect with pre-configured tenant's credentials
        
       To provide tenant's credentials on the fly:

        connect("tenant_chief", "secretPassword")

    6. Check response

       When the call is passing a block in one of the Z_Client methods (get,
       put, post, or delete), the http response body is passed back to
       the block.

       If no block is passed, the response body is returned directly.

       Both the HTTP Status Code and Response Phrase area always included
       in the response object ZAPIResp. If the invocation had been successful,
       ZAPIResp also contains the body of the HTTP response.

       The response attributes can be addressed like attributes. For
       instance:

            response.nextPage
            response.subscription[0].subscriptionNumber

    7. Catch exceptions

       If the syntax of the arguments are wrong, the SDK will raise an
       ArgumentError with the corresponding diagnostic message.

       If there is an exception while the call is in progress via the httpclient
       library a RuntimeError will be raised, and stack trace will also be
       logged in both the sdk and api log files.

    8. Follow the "nextPage"

       When issuing a GET call, sometimes there are multiple pages of response
       returned.

       This is indicated by the presence of the "nextPage" key in the response
       body.

       For example, in the get_all method of the payment_method manager,
       if the nextPage key is present in the response, pass nextPage
       as the url and make a recursive call.

    9. Iterate ZAPIResponse programmatically

       See sample class zapiresp_iterator.rb.

Author

    Zuora Inc.

Copyright

    Copyright (c) 2012-2013 Zuora Inc. (http://www.zuora.com).
    See License for details
