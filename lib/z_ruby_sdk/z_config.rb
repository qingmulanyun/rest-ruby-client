# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

# Z_Config handles sdk configuration
class Z_Config

  def initialize
    # The presence of a local config file in the current directory
    # supercedes the one in the sdk
    @config_file = File.join(Dir.pwd, Z_Constants::CONFIG_FILE)

    unless File.exists?(@config_file)
      @config_file = File.join(
        File.expand_path("#{File.dirname(__FILE__)}/../../config"),
          Z_Constants::CONFIG_FILE)
    end
  end

  # store this only instance in a class variable
  @@z_config = Z_Config.new

  # z_config is a singleton. There can only be one instance
  def self.instance
    @@z_config
  end

  # Attempt to load the resolved config file
  def load?
    # if file not found. Exit ...
    unless File.exists?(@config_file)
      error_msg = "Configuration file #{@config_file} missing"
      Z_Logger.instance.log(error_msg, Z_Constants::LOG_SDK)
      raise RuntimeError, error_msg
    end

    Z_Logger.instance.log("Loading configuration file #{@config_file} ...", Z_Constants::LOG_SDK)

    # load and log all properties
    for file in Dir.glob(@config_file)
      @properties = YAML.load(ERB.new(File.read file).result)
    end
    @properties.keys.sort.each {|prop|
      if prop.include? "password"
        Z_Logger.instance.log("#{prop} set to ********", Z_Constants::LOG_SDK)
      else
        Z_Logger.instance.log("#{prop} set to #{get_val(prop)}", Z_Constants::LOG_SDK)
      end
    }

    Z_Logger.instance.log("Configuration file #{@config_file} successfully loaded.", Z_Constants::LOG_SDK)
  end

  # return the value of the key
  def get_val(prop)
    @properties[prop]
  end

  # Use the instance method to access this object only
  private_class_method :new

end
