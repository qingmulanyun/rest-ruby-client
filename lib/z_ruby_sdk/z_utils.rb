# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

module ZUtils
  # get thread id of current thread
  def self.thread_id(t=nil)
    t ? t.inspect.split(/Thread:0x/)[1].split(/dead>/) :
      Thread.current.inspect.split(/Thread:0x/)[1].split(/run>/)
  end
end
