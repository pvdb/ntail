require 'net/http'

require 'rubygems'
require 'rainbow'

module NginxTail
  class LogLine

    def self.component_to_module_name(component)
      # this mimicks the ActiveSupport::Inflector.camelize() method in Rails...
      component.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
    
    def self.component_to_ntail_module(component)
      # this mimicks the ActiveSupport::Inflector.constantize() method in Rails...
      NginxTail.const_get(self.component_to_module_name(component))
    end

    attr_reader :raw_line
    attr_reader :parsable

    COMPONENTS = [
      :remote_addr,
      :remote_user,
      :time_local,
      :request,
      :status,
      :body_bytes_sent,
      :http_referer,
      :http_user_agent,
      :proxy_addresses,
    ]
    
    COMPONENTS.each do |symbol|
      attr_reader symbol
      include component_to_ntail_module(symbol)
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
      include component_to_ntail_module(symbol)
    end

    #
    # http://wiki.nginx.org/NginxHttpLogModule#log_format - we currently only support the default "combined" log format...
    #

    NGINX_LOG_PATTERN = Regexp.compile(/\A(\S+) - (\S+) \[([^\]]+)\] "([^"]+)" (\S+) (\S+) "([^"]*?)" "([^"]*?)"( "([^"]*?)")?\Z/)
    NGINX_REQUEST_PATTERN = Regexp.compile(/\A(\S+) (.*?) (\S+)\Z/)
    NGINX_PROXY_PATTERN = Regexp.compile(/\A "([^"]*)"\Z/)

    def initialize(line)
      @parsable = if NGINX_LOG_PATTERN.match(@raw_line = line)
        @remote_addr, @remote_user, @time_local, @request, @status, @body_bytes_sent, @http_referer, @http_user_agent, @proxy_addresses = $~.captures
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
    
    def to_s()
      # simple but boring:
      # raw_line.to_s
      color = if redirect_status?
        :yellow
      elsif !success_status?
        :red
      else
        :default
      end
      "%s - %#{Sickill::Rainbow.enabled ? 15 + 9 : 15}s - %s - %s - %s - %s" % [
        to_date_s.foreground(color),
        remote_address.foreground(color),
        status.foreground(color),
        (uri || "-").foreground(color),
        to_agent_s.foreground(color),
        to_referer_s.foreground(color).inverse
      ]
    end
  
    CONVERSIONS = [
  
      :to_date,
      :to_date_s,
      
      :to_agent,
      :to_agent_s,

      :to_host_name,
      :to_refering_website,
      
      :to_country_s,
      :to_city_s,
    
    ]

    def self.log_subcomponent?(subcomponent)
      # TODO replace with some clever meta-programming...
      SUBCOMPONENTS.include?(subcomponent)
    end
    
    def self.log_component?(component)
      # TODO replace with some clever meta-programming...
      COMPONENTS.include?(component)
    end
    
    def self.log_conversion?(conversion)
      # TODO replace with some clever meta-programming...
      CONVERSIONS.include?(conversion)
    end
    
    def self.log_directive?(directive)
      (directive == :full) or log_conversion?(directive) or log_component?(directive) or log_subcomponent?(directive)
    end

    #
    # extraction filters for log line components
    #

    def self.regexp_for_remote_address(remote_address)
      Regexp.compile(/^(#{remote_address}) /)
    end

    def self.regexp_for_request(request)
      Regexp.compile(/^([^"]+) "([^"]*#{request}[^"]*)" /)
    end

    def self.regexp_for_status(status)
      Regexp.compile(/ "([^"]+)" (#{status}) /)
    end

    def self.regexp_for_http_referer(http_referer)
      Regexp.compile(/" .* "([^"]*#{http_referer}[^"]*)" "/)
    end

    def self.regexp_for_http_user_agent(http_user_agent)
      Regexp.compile(/ "([^"]*#{http_user_agent}[^"]*)"$/)
    end
 
    #
    # validation of log line components
    #

    def self.valid_status?(status)
      if /\A(\d{1,3})\Z/ =~ status
        return $~.captures.all? { |i| 100 <= i.to_i and i.to_i < 600 }
      end
      return false
    end

    def self.valid_v4?(addr)
      if /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/ =~ addr
        return $~.captures.all? {|i| i.to_i < 256}
      end
      return false
    end

    def self.valid_request?(request) true ; end
    def self.valid_referer?(referer) true ; end
    def self.valid_user_agent?(user_agent) true ; end

    #
    # "GET /xd_receiver.html HTTP/1.1"
    # "GET /crossdomain.xml HTTP/1.1"
    # "GET /favicon.ico HTTP/1.1"
    # "GET /robots.txt HTTP/1.0"
    #

    AUTOMATED_REQUESTS = [
      Regexp.compile('^[A-Z]+ \/xd_receiver.html'),
      Regexp.compile('^[A-Z]+ \/crossdomain.xml'),
      Regexp.compile('^[A-Z]+ \/favicon.ico'),
      Regexp.compile('^[A-Z]+ \/robots.txt'),
      nil
    ].compact!
  
    def self.automated_request?(request) !AUTOMATED_REQUESTS.detect { |automated_request_regexp| request.match(automated_request_regexp) }.nil? end
    def      automated_request?()        self.class.automated_request?(self.request) ; end

    # 
    # subdirectories of the "public" folder in the web root,
    # which - in a typical Rails setup - are served by nginx
    #

    STATIC_REPOS = %w{
      flash
      html
      images
      javascripts
      movies
      newsletters
      pictures
      stylesheets
      xml
    }

    STATIC_URIS = STATIC_REPOS.map { |repo| Regexp.compile("^\/#{repo}\/") }
  
    def self.static_uri?(uri) !STATIC_URIS.detect { |static_uri_regexp| uri.match(static_uri_regexp) }.nil? end
    def      static_uri?()    self.class.static_uri?(self.uri); end

    STATIC_REQUESTS = STATIC_REPOS.map { |repo| Regexp.compile("^[A-Z]+ \/#{repo}\/") }
  
    def self.static_request?(request) !STATIC_REQUESTS.detect { |static_request_regexp| request.match(static_request_regexp) }.nil? end
    def      static_request?()        self.class.static_request?(self.request) ; end

    NGINX_MAGIC_STATUS = '499'   # ex-standard HTTP response code specific to nginx, in addition to http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    UNPROCESSABLE_ENTITY = '422' # not supported by 'net/http' (Net::HTTPResponse::CODE_TO_OBJ["422"] == nil), see also: http://www.ruby-forum.com/topic/98002 

    # Informational 1xx
    def self.information_status?(status) (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPInformation ; end
    def      information_status?()       self.class.information_status?(self.status) ; end

    # Successful 2xx
    def self.success_status?(status) (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPSuccess ; end
    def      success_status?()       self.class.success_status?(self.status) ; end

    # Redirection 3xx
    def self.redirect_status?(status) (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPRedirection ; end
    def      redirect_status?()       self.class.redirect_status?(self.status) ; end

    # Client Error 4xx
    def self.client_error_status?(status) (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPClientError ; end
    def      client_error_status?()       self.class.client_error_status?(self.status) ; end

    # Internal Server Error 5xx
    def self.server_error_status?(status) (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPServerError ; end
    def      server_error_status?()       self.class.server_error_status?(self.status) ; end
  
  end # class LogLine
end # module NginxTail
