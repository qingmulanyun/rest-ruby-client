# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

module Utils
  # get thread id of current thread
  def thread_id(t=nil)
    t ? t.inspect.split(/Thread:0x/)[1].split(/dead>/) :
      Thread.current.inspect.split(/Thread:0x/)[1].split(/run>/)
  end
end
