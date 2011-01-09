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
        to_request_s.foreground(color),
        to_agent_s.foreground(color),
        to_referer_s.foreground(color).inverse
      ]
    end
  
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

  end # class LogLine
end # module NginxTail
