# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

# Z_API handles interactions between Z_Client and HTTPClient
class Z_API

  # Accept default tenant's credentials from config.yml
  # There is one z_api object per z_client
  def initialize(default_tenant_user_id, default_tenant_password)
    @default_tenant_user_id = default_tenant_user_id
    @default_tenant_password = default_tenant_password
  end

  # tenant credentials can be changed via CONNECT
  def set_connect_credentials(connect_tenant_user_id, connect_tenant_password)
    @connect_tenant_user_id = connect_tenant_user_id
    @connect_tenant_password = connect_tenant_password
  end

  # Do HTTP GET
  def exec_get_api(uri, query_string)    
    headers = {}

    # indicate accept response body in JSON
    headers['Accept'] = 'application/json'

    # for a GET call, chase redirects up to 10 times
    headers['follow_redirect'] = true

    # For a nextPage call the uri is the URL
    if uri.downcase.start_with?("http")
      url = uri
    else
      # turn the resource uri to a full URL
      url = Z_Config.instance.get_val("rest_api_endpoint") +
        '/' + Z_Config.instance.get_val("rest_api_version") + uri
    end

    # Trace pre-call arguments if api_trace is on
    if Z_Config.instance.get_val("api_trace")
      Z_Logger.instance.log("***** PRE-API TRACE *****", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP method = GET", Z_Constants::LOG_API)
      Z_Logger.instance.log("URL = #{url}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Query String = #{query_string.pretty_inspect.chomp}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Headers =\n#{headers.pretty_inspect.chomp}", Z_Constants::LOG_API)
    end

    # get a ssl pipe (httpclient), execute, trace response
    begin
      trace_post_api_response(ssl_pipe.get(url, query_string || {}, headers))
    rescue Exception => e
      Z_Logger.instance.log(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "Fatal error in executing HTTP GET #{url}"
    end
  end

  # Do HTTP PUT
  def exec_put_api(uri, request_body)
    headers = {}

    # indicate accept response body in JSON
    headers['Accept'] = 'application/json'

    # For a PUT call, request body content is in JSON
    headers['Content-Type'] = 'application/json'

    # turn the resource uri to a full URL
    url = Z_Config.instance.get_val("rest_api_endpoint") +
      '/' + Z_Config.instance.get_val("rest_api_version") + uri

    # Trace pre-call arguments if api_trace is on
    if Z_Config.instance.get_val("api_trace")
      Z_Logger.instance.log("***** PRE-API TRACE *****", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP method = PUT", Z_Constants::LOG_API)
      Z_Logger.instance.log("URL = #{url}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Request Body = #{request_body.pretty_inspect.chomp}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Headers =\n#{headers.pretty_inspect.chomp}", Z_Constants::LOG_API)
    end

    # get a ssl pipe (httpclient), execute, trace response
    begin
      trace_post_api_response(ssl_pipe.put(url, request_body.to_json, headers))
    rescue Exception => e
      Z_Logger.instance.log(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "Fatal error in executing HTTP PUT #{url}I"
    end
  end

  # Do HTTP POST
  def exec_post_api(uri, request_body)
    headers = {}

    # indicate accept response body in JSON
    headers['Accept'] = 'application/json'

    # For file upload dont need to set content type
    unless uri.downcase.include?(Z_Constants::UPLOAD_USAGE_URL)
     # For a POST call, request body content is in JSON
      headers['Content-Type'] = 'application/json'
    end
    
    # For a connect call the version number is not in the url
    if uri.downcase.include?(Z_Constants::CONNECTION_URI)
      # put tenant's credentials in request header
      url = Z_Config.instance.get_val("rest_api_endpoint") + uri
      headers['apiAccessKeyId'] = tenant_user_id_to_use
      headers['apiSecretAccessKey'] = tenant_password_to_use
    else
      # turn the resource uri to a full URL
      url = Z_Config.instance.get_val("rest_api_endpoint") +
        '/' + Z_Config.instance.get_val("rest_api_version") + uri
    end

    # Trace pre-call arguments if api_trace is on
    if Z_Config.instance.get_val("api_trace")
      Z_Logger.instance.log("***** PRE-API TRACE *****", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP method = POST", Z_Constants::LOG_API)
      Z_Logger.instance.log("URL = #{url}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Request Body = #{request_body.pretty_inspect.chomp}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Headers =\n#{headers.pretty_inspect.chomp}", Z_Constants::LOG_API)
    end
    
    # get a ssl pipe (httpclient), execute, trace response
    begin
      # If this is a POST upload we need to pass the file
      # object to httpclient, which will read the file
      # and put it in the request body using http multipart POST
      if uri.downcase.include?(Z_Constants::UPLOAD_USAGE_URL)
        File.open(request_body["filename"]) do |file|
          request_body = {'file' => file}
          trace_post_api_response(ssl_pipe.post(url, request_body, headers))
        end
      else
        trace_post_api_response(ssl_pipe.post(url, request_body.to_json, headers))
      end
    rescue Exception => e
      Z_Logger.instance.log(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "Fatal error in executing HTTP POST #{url}"
    end
  end

  # Do HTTP DELETE
  def exec_delete_api(uri, query_string)
    headers = {}

    # indicate accept response body in JSON
    headers['Accept'] = 'application/json'

    # turn the resource uri to a full URL
    url = Z_Config.instance.get_val("rest_api_endpoint") +
      '/' + Z_Config.instance.get_val("rest_api_version") + uri

    # Trace pre-call arguments if api_trace is on
    if Z_Config.instance.get_val("api_trace")
      Z_Logger.instance.log("***** PRE-API TRACE *****", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP method = DELETE", Z_Constants::LOG_API)
      Z_Logger.instance.log("URL = #{url}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Query String = #{query_string.pretty_inspect.chomp}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Headers =\n#{headers.pretty_inspect.chomp}", Z_Constants::LOG_API)
    end

    # get a ssl pipe (httpclient), execute, trace response
    begin
      trace_post_api_response(ssl_pipe.delete(url, query_string || {}, headers))
    rescue Exception => e
      Z_Logger.instance.log(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "Fatal error in executing HTTP DELETE #{url}"
    end
  end

  private

  # Print some HTTP artifacts and response
  def trace_post_api_response(response)
    # parse the content of the response into a hash
    begin
      api_resp_in_hash = JSON.parse(response.content)
    rescue
    end

    # add HTTP status code and reason inside
    api_resp_in_hash ||= {}
    api_resp_in_hash["httpStatusCode"] = response.status
    api_resp_in_hash["httpReasonPhrase"] = response.reason

    if Z_Config.instance.get_val("api_trace")
      # response is of type HTTP::Message, HTTP::Message::Headers, HTTP:Message::Body
      Z_Logger.instance.log("***** POST-API RESPONSE TRACE *****", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP method = #{response.header.request_method}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Proxy = #{ssl_pipe.proxy.to_s}", Z_Constants::LOG_API)
      Z_Logger.instance.log("URL = #{response.header.request_uri.to_s}", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP status = #{response.status}", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP reason = #{response.reason}", Z_Constants::LOG_API)
      Z_Logger.instance.log("HTTP version = #{response.header.http_version}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Server = #{response.header['Server']}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Transfer-Encoding = #{response.header['Transfer-Encoding']}", Z_Constants::LOG_API)
      response.header['Set-Cookie'].each {|value|
        Z_Logger.instance.log("Cookie = #{value}", Z_Constants::LOG_API)
      }
      Z_Logger.instance.log("Connection = #{response.header['Connection']}", Z_Constants::LOG_API)
      Z_Logger.instance.log("Content Type = #{response.contenttype}", Z_Constants::LOG_API)
      # deserialize JSON string into hash, pretty print it
      Z_Logger.instance.log("API Response =\n#{JSON.pretty_generate(api_resp_in_hash)}", Z_Constants::LOG_API)
    end

    # convert hash to a ruby object and return result
    ZAPIResp.new(api_resp_in_hash)
  end
  
  # allocate a thread safe httpclient to this tenant
  # The current design shares one httpclient among multiple threads
  # connecting to the same tenant. In most cases there will only be
  # 1 httpclient. We could have everyone share the same client too but
  # we want to be cautious
  def ssl_pipe
    # initialize a cache if it hasn't been done so
    @@z_httpclient_cache ||= {}

    # Use the same z_httpclient object for all callers sharing the same
    # tenant user id
    if @@z_httpclient_cache.has_key?(tenant_user_id_to_use.to_sym)
      @z_httpclient = @@z_httpclient_cache[tenant_user_id_to_use.to_sym]
    else
      # create and configure a httpclient based on configuration
      @z_httpclient = create_httpclient
      config_httpclient

      # cache this httpclient by tenant user id
      @@z_httpclient_cache[tenant_user_id_to_use.to_sym] = @z_httpclient
      @z_httpclient
    end
  end

  # instantiate a flavor of httpclient, with or without proxy
  def create_httpclient
    if Z_Config.instance.get_val("proxy_used")
      HTTPClient.new(Z_Config.instance.get_val("proxy_url"),
        Z_Config.instance.get_val("user_agent"))
    else
      HTTPClient.new(nil,
        Z_Config.instance.get_val("user_agent"))
    end
  end

  # set all the nuts and bolts for httpclient
  def config_httpclient
    # set timeout parameters
    @z_httpclient.connect_timeout = Z_Config.instance.get_val("http_connect_timeout")
    @z_httpclient.send_timeout = Z_Config.instance.get_val("http_send_timeout")
    @z_httpclient.receive_timeout = Z_Config.instance.get_val("http_receive_timeout")

    # Configure proxy credentials if proxy requires basic authentication
    if Z_Config.instance.get_val("proxy_used") &&
       Z_Config.instance.get_val("proxy_auth")
      @z_httpclient.set_proxy_auth(Z_Config.instance.get_val("proxy_user"), Z_Config.instance.get_val("proxy_password"))
    end

    # Configure SSL. Use our own Root Cert if verifying peer cert is needed
    if Z_Config.instance.get_val("ssl_verify_peer")
      @z_httpclient.ssl_config.clear_cert_store
      @z_httpclient.ssl_config.set_trust_ca(Z_Constants::CA_BUNDLE_PEM)
    else
      @z_httpclient.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  # resolve final tenant user id to use
  def tenant_user_id_to_use
    # Credentials present in a CONNECT call always prevails
    @connect_tenant_user_id.nil? ? @default_tenant_user_id : @connect_tenant_user_id
  end

  # resolve final tenant password to use
  def tenant_password_to_use
    # Credentials present in a CONNECT call always prevails
    @connect_tenant_password.nil? ? @default_tenant_password : @connect_tenant_password
  end
end