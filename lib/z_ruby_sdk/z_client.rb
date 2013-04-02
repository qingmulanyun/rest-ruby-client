# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

# Z_Client handles interactions between the API caller and handler
class Z_Client

  # Z_Client is Zuora REST API syntax specific
  def initialize
    # Use default tenant credentials in config.yml if present
    @default_tenant_user_id = Z_Config.instance.get_val("default_tenant_user_id")
    @default_tenant_password = Z_Config.instance.get_val("default_tenant_password")

    # Z_API is the api handler for this z_client
    @z_api = Z_API.new(@default_tenant_user_id, @default_tenant_password)
  end

  # Validate and process a REST GET API
  # arguments are in z_api_args
  def get(z_api_args)
    # validate resource URI
    error_msg = bad_uri?(z_api_args.uri)
    raise ArgumentError, error_msg if error_msg

    # For GET, reject if request_body is present
    request_body = z_api_args.req_body
    if request_body
      error_msg = "Extraneous request body argument #{request_body.pretty_inspect.chomp} found."
      Z_Logger.instance.log(error_msg)
      raise ArgumentError, error_msg
    end

    # verify tenant's credential existence
    error_msg = credentials_exist?
    raise ArgumentError, error_msg if error_msg

    # may or may not have query string
    query_string = z_api_args.query_string ?
      z_api_args.query_string.to_hash : {}

    begin
      # if caller has a block, yield with response body after invocation
      if block_given?
        yield @z_api.exec_get_api(z_api_args.uri, query_string)
      else
        @z_api.exec_get_api(z_api_args.uri, query_string)
      end
    rescue Exception => e
      Z_Logger.instance.log(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "HTTP GET Exception. Please see logs for details."
    end
  end

  # Validate and process a REST POST API
  # arguments are in z_api_args
  def post(z_api_args)
    # validate resource URI
    error_msg = bad_uri?(z_api_args.uri)
    raise ArgumentError, error_msg if error_msg

    # For POST, reject if query string is present
    query_string = z_api_args.query_string
    if query_string
      error_msg = "Extraneous query string argument #{query_string.pretty_inspect.chomp} found."
      Z_Logger.instance.log(error_msg)
      raise ArgumentError, error_msg
    end

    # For POST CONNECTION, reject if request_body is present
    request_body =  z_api_args.req_body
    if z_api_args.uri.include?(Z_Constants::CONNECTION_URI)
      if request_body
        error_msg = "Extraneous request body argument #{request_body.pretty_inspect.chomp} found."
        Z_Logger.instance.log(error_msg)
        raise ArgumentError, error_msg
      else
        # For POST CONNECTION, extract tenant user id and password
        @connect_tenant_user_id = z_api_args.headers.apiAccessKeyId
        @connect_tenant_password = z_api_args.headers.apiSecretAccessKey

        # override the default credentials of z_api when created
        @z_api.set_connect_credentials(@connect_tenant_user_id,
          @connect_tenant_password)
        z_api_args.req_body = ZAPIArgs.new
      end
    else
      # Other than POST CONNECTION, reject if request_body is missing
      unless request_body
        error_msg = "Missing request body argument."
        Z_Logger.instance.log(error_msg)
        raise ArgumentError, error_msg
      end
    end

    # verify tenant's credential existence
    error_msg = credentials_exist?
    raise ArgumentError, error_msg if error_msg

    begin
      # if we have a block, yield
      if block_given?
        yield @z_api.exec_post_api(z_api_args.uri, z_api_args.req_body.to_hash)
      else
        @z_api.exec_post_api(z_api_args.uri, z_api_args.req_body.to_hash)
      end
    rescue Exception => e
      Z_Logger.instance.log(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "HTTP POST Exception. Please see logs for details."
    end
  end
  
  # Validate and process a REST PUT API
  def put(z_api_args)
    # validate the resource URI
    error_msg = bad_uri?(z_api_args.uri)
    raise ArgumentError, error_msg if error_msg

    # For PUT, reject if query string is present
    query_string = z_api_args.query_string
    if query_string
      error_msg = "Extraneous query string argument #{query_string.pretty_inspect.chomp} found."
      Z_Logger.instance.log(error_msg)
      raise ArgumentError, error_msg
    end

    # For PUT, reject if request_body is missing
    request_body = z_api_args.req_body
    unless request_body
      error_msg = "Missing request_body argument."
      Z_Logger.instance.log(error_msg)
      raise ArgumentError, error_msg
    end

    # verify tenant's credential existence
    error_msg = credentials_exist?
    raise ArgumentError, error_msg if error_msg

    begin
      # if the caller has a block, yield with response after invocation
      if block_given?
        yield @z_api.exec_put_api(z_api_args.uri, z_api_args.req_body.to_hash)
      else
        @z_api.exec_put_api(z_api_args.uri, z_api_args.req_body.to_hash)
      end
    rescue Exception => e
      Z_logger.instance.log(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "HTTP PUT Exception. Please see logs for details."
    end
  end

  # Validate and process a REST DELETE API call
  def delete(z_api_args)
    # validate the resource URL
    error_msg = bad_uri?(z_api_args.uri)
    raise ArgumentError, error_msg if error_msg

    # For DELETE, reject if request_body is present
    request_body = z_api_args.req_body
    if request_body
      error_msg = "Extraneous request body argument #{request_body.pretty_inspect.chomp} found."
      Z_Logger.instance.log(error_msg)
      raise ArgumentError, error_msg
    end

    # verify tenant's credential existence
    error_msg = credentials_exist?
    raise ArgumentError, error_msg if error_msg

    # may or may not have query string
    query_string = z_api_args.query_string ? z_api_args.query_string.to_hash : {}

    begin
      # if the caller has a block, yield with response after invocation
      if block_given?
        yield @z_api.exec_delete_api(z_api_args.uri, query_string)
      else
        @z_api.exec_delete_api(z_api_args.uri, query_string)
      end
    rescue Exception => e
      Z_Logger.instance(e.message)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      raise RuntimeError, "HTTP DELETE Exception. Please see logs for details."
    end
  end

  private

  # perform sanity check on a resource uri
  def bad_uri?(uri)
    # Reject if missing uri
    if uri.nil?
      error_msg = "URI is missing."
      Z_Logger.instance.log(error_msg)
      return error_msg
    end

    # Reject if incorrect uri
    unless Z_Config.instance.get_val("rest_api_endpoint") + '/' +
      Z_Config.instance.get_val("rest_api_version") + uri =~ URI::regexp
      error_msg = "URI #{uri} is an incorrect URL."
      Z_Logger.instance.log(error_msg)
    end

    nil
  end

  # Verify if there were any tenant's credentials that can be used
  # while processing a REST API call
  def credentials_exist?
    # reject if both default and connect credentials are missing
    if (@default_tenant_user_id.nil? || @default_tenant_user_id.empty? ||
        @default_tenant_password.nil? || @default_tenant_password.empty?) &&
        (@connect_tenant_user_id.nil? || @connect_tenant_user_id.empty? ||
        @connect_tenant_password.nil? || @connect_tenant_password.empty?)
      error_msg = "Unable to establish valid tenant's credentials in a CONNECT call or configuration."
    end

    nil
  end
end
