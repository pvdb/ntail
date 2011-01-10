NTAIL_NAME = 'ntail'
NTAIL_VERSION = '0.0.1'

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
require 'ntail/log_line'
require 'ntail/application'

# That's all, Folks!