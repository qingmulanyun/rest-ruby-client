# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

# Set up the environment for the SDK
class Z_Env
  def initialize
    # Ready the loggers
    Z_Logger.instance.log "***** SDK loggers initialized *****"

    # Load the configuration properties
    begin
      Z_Config.instance.load?
    rescue RuntimeError => e
      Z_Logger.instance.log(e.message, Z_Constants::LOG_SDK)
      Z_Logger.instance.log(e.backtrace.join("\n"))
      puts "Unable to initialize SDK environment. Please see log for details."
      exit
    end
  end

  @@z_env = Z_Env.new

  # Z_Env is a singleton object. There can only be one instance
  def self.instance
    @@z_env
  end

  # User the instance method to access Z_Env object
  private_class_method :new
end




