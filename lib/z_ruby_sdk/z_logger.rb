# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

# Z_Logger is a wrapper object of the standard ruby logger
class Z_Logger

  def initialize
    # All log files inside a subdirectory ...
    sdk_log_dir = File.join(Dir.pwd, Z_Constants::LOG_DIR)

    # ... under the current running directory
    Dir.mkdir sdk_log_dir unless File.exists? sdk_log_dir

    # 2 log files, 4M each, 3 rolling copies
    @sdk_logger = Logger.new(File.join(sdk_log_dir, Z_Constants::LOG_FILENAME), shift_age = 3, shift_size = 4096000)
    @api_logger = Logger.new(File.join(sdk_log_dir, Z_Constants::API_TRACE_FILENAME), shift_age = 3, shift_size = 4096000)

    # msg format includes thread ID of the API calling thread
    [@sdk_logger, @api_logger].each {|a_logger|
      a_logger.level = Logger::INFO
      class << a_logger
        def format_message (severity, timestamp, progname, msg)
          "[#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}.#{("%.3f" % timestamp.to_f).split('.')[1]}] #{ZUtils.thread_id} #{msg}\n"
        end
      end
    }
  end

  @@z_logger = Z_Logger.new

  # Z_Logger is a singleton object. There can only be one instance.
  def self.instance
    @@z_logger
  end

  # log on api_trace.log, ruby_sdk.log, or both
  def log(msg, logdest=Z_Constants::LOG_BOTH)
    case logdest
    when Z_Constants::LOG_SDK
      @sdk_logger.info msg if @sdk_logger
    when Z_Constants::LOG_API
      @api_logger.info msg if @api_logger
    else
      @sdk_logger.info msg if @sdk_logger
      @api_logger.info msg if @api_logger
    end 
  end

  # Use the instance method to access Z_Logger object
  private_class_method :new

end
