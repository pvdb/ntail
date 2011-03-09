NTAIL_NAME = 'ntail'
NTAIL_VERSION = '0.0.1'

# module methods to be used as functions...
module NginxTail
  module Inflections
    def self.component_to_module_name(component)
      # this mimicks the ActiveSupport::Inflector.camelize() method in Rails...
      component.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
    def self.component_to_ntail_module(component)
      # this mimicks the ActiveSupport::Inflector.constantize() method in Rails...
      NginxTail.const_get(self.component_to_module_name(component))
    end
  end
end

# so-called components...
require 'ntail/remote_addr'
require 'ntail/remote_user'
require 'ntail/time_local'
require 'ntail/request'
require 'ntail/status'
require 'ntail/body_bytes_sent'
require 'ntail/http_referer'
require 'ntail/http_user_agent'
require 'ntail/proxy_addresses'

# so-called sub-components...
require 'ntail/http_method'
require 'ntail/uri'
require 'ntail/http_version'

# additional utility functions...
require 'ntail/known_ip_addresses'
require 'ntail/local_ip_addresses'

# the formatting classes...
require 'ntail/node.rb'
require 'ntail/formatting.rb'

# the core classes...
require 'ntail/log_line.rb'
require 'ntail/options.rb'
require 'ntail/application.rb'

# That's all, Folks!
