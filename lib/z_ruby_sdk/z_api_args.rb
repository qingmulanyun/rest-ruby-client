# Copyright (c) 2013 Zuora Inc.
#
# Zuora Ruby SDK for REST API support
#

include Hashie

# ZAPIArgs is synonymous to the MASH class in the Hashie gem
ZAPIArgs = Mash

# We use update as one our attributes. This method confuses with our attribute
ZAPIArgs.send :undef_method, :update