require 'net/http'

require 'rubygems'
require 'rainbow'

module NginxTail
  class LogLine

    attr_reader :raw_line
    attr_reader :parsable
    attr_reader :filename
    attr_reader :line_number

    COMPONENTS = [ # formatting token:
      :remote_addr,     # %a
      :remote_user,     # %u
      :time_local,      # %t
      :request,         # %r
      :status,          # %s
      :body_bytes_sent, # %b
      :http_referer,    # %R
      :http_user_agent, # %U
      :proxy_addresses, # %p
    ]

    COMPONENTS.each do |symbol|
      attr_reader symbol
      include Inflections.component_to_ntail_module(symbol)
    end

    APACHE_COMPONENTS = [
      :server_name,     # %V
      # :remote_addr,     # %h
      :remote_log_name, # %l
      # :remote_user,     # %u
      # :time_local,      # %t
      # :request,         # %r
      # :status,          # %s
      # :body_bytes_sent, # %b
      # :http_referer,    # %%{Referer}i
      # :http_user_agent, # %%{User-agent}i
      :http_cookie,     # %{Cookie}i
    ]

    APACHE_COMPONENTS.each do |symbol|
      attr_reader symbol
      # include Inflections.component_to_ntail_module(symbol)
    end

    include KnownIpAddresses # module to identify known IP addresses
    include LocalIpAddresses # module to identify local IP addresses

    SUBCOMPONENTS = [
      :http_method,
      :uri,
      :http_version,
    ]

    SUBCOMPONENTS.each do |symbol|
      attr_reader symbol
      include Inflections.component_to_ntail_module(symbol)
    end

    #
    # http://httpd.apache.org/docs/2.0/mod/mod_log_config.html - we currently only support the following custom log format...
    #
    # "%V %h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Cookie}i\" %I %O %D %{deflate_ratio}n%%"
    #

    APACHE_LOG_PATTERN = Regexp.compile(/\A([\S]*) ([\S]+) ([\S]+|-) ([\S]+|-) \[([^\]]+)\] "(.*)" ([\d]+) ([\d]+|-) "(.*?)" "(.*?)" "(.*?)" .*\Z/)

    #
    # http://wiki.nginx.org/NginxHttpLogModule#log_format - we currently only support the default "combined" log format...
    #

    NGINX_LOG_PATTERN = Regexp.compile(/\A(\S+) - (\S+) \[([^\]]+)\] "([^"]+)" (\S+) (\S+) "([^"]*?)" "([^"]*?)"( "([^"]*?)")?\Z/)

    NGINX_REQUEST_PATTERN = Regexp.compile(/\A(\S+) (.*?) (\S+)\Z/)
    NGINX_PROXY_PATTERN = Regexp.compile(/\A "([^"]*)"\Z/)

    def initialize(line, filename = nil, line_number = nil)
      @filename = filename ; @line_number = line_number
      @parsable = if APACHE_LOG_PATTERN.match(@raw_line = line)
        # @remote_addr, @remote_user, @time_local, @request, @status, @body_bytes_sent, @http_referer, @http_user_agent, @proxy_addresses = $~.captures
        @server_name, @remote_addr, @remote_log_name, @remote_user, @time_local, @request, @status, @body_bytes_sent, @http_referer, @http_user_agent, @http_cookie = $~.captures
        if NGINX_REQUEST_PATTERN.match(@request)
          # counter example (ie. HTTP request that cannot by parsed)
          # 91.203.96.51 - - [21/Dec/2010:05:26:53 +0000] "-" 400 0 "-" "-"
          @http_method, @uri, @http_version = $~.captures
        end
        if @proxy_addresses and NGINX_PROXY_PATTERN.match(@proxy_addresses)
          @proxy_addresses = $~.captures.first.split(/, /)
        end
        true
      else
        false
      end
    end

    alias_method :remote_address, :remote_addr # a non-abbreviated alias, for convenience and readability...

    # for now, until we make it fancier...
    def method_missing(method, *params)
      raw_line.send method, *params
    end

    @@parser = FormattingParser.new

    @@result = @@format = nil

    def self.format= format
      unless @@result = @@parser.parse(@@format = format)
        raise @@parser.terminal_failures.join("\n")
      else
        def @@result.value(log_line, color)
          elements.map { |element| element.value(log_line, color) }.join
        end
      end
    end

    self.format = "%t - %a - %s - %r - %U - %R"

    def to_s(options = {})

      # simple but boring:
      # raw_line.to_s

      # a bit less boring:
      color = options[:color] && if redirect_status?
        :yellow
      elsif !success_status?
        :red
      else
        :default
      end
      @@result.value(self, color)

    end

  end # class LogLine
end # module NginxTail
