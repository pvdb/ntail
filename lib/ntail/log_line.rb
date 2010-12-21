require 'date'
require 'socket'
require 'net/http'

require 'rubygems'
require 'rainbow'
require 'user-agent'

begin
  require 'geoip'
rescue
  # NOOP (optional dependency)
end

module NginxTail
  class LogLine

    attr_accessor :raw_line
    attr_accessor :parsable

    attr_accessor :remote_address
    attr_accessor :remote_user
    attr_accessor :time_local
    attr_accessor :request
    attr_accessor :status
    attr_accessor :body_bytes_sent
    attr_accessor :http_referer
    attr_accessor :http_user_agent
    attr_accessor :proxy_addresses
  
    attr_accessor :http_method
    attr_accessor :uri
    attr_accessor :http_version

    #
    # http://wiki.nginx.org/NginxHttpLogModule#log_format - we currently only support the default "combined" log format...
    #

    NGINX_LOG_PATTERN = Regexp.compile(/\A(\S+) - (\S+) \[([^\]]+)\] "([^"]+)" (\S+) (\S+) "([^"]*?)" "([^"]*?)"( "([^"]*?)")?\Z/)
    NGINX_REQUEST_PATTERN = Regexp.compile(/\A(\S+) (.*?) (\S+)\Z/)
    NGINX_PROXY_PATTERN = Regexp.compile(/\A "([^"]*)"\Z/)

    def initialize(line)
      @parsable = if NGINX_LOG_PATTERN.match(@raw_line = line)
        @remote_address, @remote_user, @time_local, @request, @status, @body_bytes_sent, @http_referer, @http_user_agent, @proxy_addresses = $~.captures
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
      "%s - %#{Sickill::Rainbow.enabled ? 15 + 9 : 15}s - %s - %s - %s" % [
        to_date.strftime("%Y-%m-%d %X").foreground(color),
        remote_address.foreground(color),
        status.foreground(color),
        (uri || "-").foreground(color),
        to_agent_s.foreground(color)
      ]
    end

    COMPONENTS = [
    
      :remote_address,
      :remote_user,
      :time_local,
      :request,
      :status,
      :body_bytes_sent,
      :http_referer,
      :http_user_agent,
      :proxy_addresses,

    ]

    SUBCOMPONENTS = [
    
      :http_method,
      :uri,
      :http_version,
    
    ]
  
    CONVERSIONS = [
  
      :to_date,
      :to_agent,

      :to_host_name,
      :to_country,
      :to_city,
    
    ]

    def self.log_subcomponent?(subcomponent) SUBCOMPONENTS.include?(subcomponent) ; end # TODO replace with some clever meta-programming...
    def self.log_component?(component) COMPONENTS.include?(component) ; end             # TODO replace with some clever meta-programming...
    def self.log_conversion?(conversion) CONVERSIONS.include?(conversion) ; end         # TODO replace with some clever meta-programming...
    def self.log_directive?(directive) (directive == :full) or log_conversion?(directive) or log_component?(directive) or log_subcomponent?(directive) ; end

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
    # conversion of log line components
    #

    # >> DateTime.strptime("13/Apr/2010:04:45:51 +0100", '%d/%b/%Y:%T %z').to_s
    # => "2010-04-13T04:45:51+01:00"
    # >> DateTime.strptime("13/Apr/2010:04:45:51 +0100", '%d/%b/%Y:%H:%M:%S %z').to_s
    # => "2010-04-13T04:45:51+01:00"
    # >> _

    def to_date() DateTime.strptime(self.time_local, '%d/%b/%Y:%T %z') ; end

    class SearchBot < Agent
      attr_accessor :name
      attr_accessor :os
      def initialize(string)
        super string
        @name = self.class.name_for_user_agent(string)
        @os = self.class.os_for_user_agent(string)
      end
      def self.name_for_user_agent string
        case string
          when  GOOGLE_BOT then "googlebot"
          when     MSN_BOT then "msnbot"
          when   YAHOO_BOT then "yahoo_slurp"
          when   ALEXA_BOT then "ia_archiver"
          when PINGDOM_BOT then "pingdom_bot"
          when  YANDEX_BOT then "yandex_bot"
          else super(string)
        end
      end
      def self.os_for_user_agent string
        case string
          when  GOOGLE_BOT then "google.com"
          when     MSN_BOT then "msn.com"
          when   YAHOO_BOT then "yahoo.com"
          when   ALEXA_BOT then "alexa.com"
          when PINGDOM_BOT then "pingdom.com"
          when  YANDEX_BOT then "yandex.com"
          else super(string)
        end
      end
    end

    def to_agent() 
      if known_search_bot?
        SearchBot.new(self.http_user_agent)
      else
        Agent.new(self.http_user_agent)
      end
    end
    
    def to_agent_s()
      agent = self.to_agent ; "(%s, %s)" % [agent.name, agent.os]
    end

    def to_host_name()
      Socket::getaddrinfo(self.remote_address,nil)[0][2]
    end
    
    if defined? GeoIP # ie. if the optional GeoIP gem is installed
      
      if File.exists?('/usr/share/GeoIP/GeoIP.dat')
        def to_country()
          record = GeoIP.new('/usr/share/GeoIP/GeoIP.dat').country(self.remote_address) ; record ? record[5] : 'N/A'
        end
      end
      
      if File.exists?('/usr/share/GeoIP/GeoIPCity.dat')
        def to_city()
          record = GeoIP.new('/usr/share/GeoIP/GeoIPCity.dat').city(self.remote_address) ; record ? record[7] : 'N/A'
        end
      end
      
    end

    #
    # downstream proxy servers
    #

    PROXY_IP_ADDRESSES = %w{
      192.168.0.2
      192.168.0.3
      192.168.0.4
    }

    def self.proxy_ip_address?(remote_address) PROXY_IP_ADDRESSES.include?(remote_address) ; end
    def      proxy_ip_address?() self.class.proxy_ip_address?(self.remote_address) ; end

    #
    # known IP addresses, for filtering purposes
    #
  
    OFFICE_IP_ADDRESSES = %w{
    }

    def self.office_ip_address?(remote_address) OFFICE_IP_ADDRESSES.include?(remote_address) ; end
    def      office_ip_address?() self.class.office_ip_address?(self.remote_address) ; end

    #
    # Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    # Googlebot-Image/1.0
    # msnbot/2.0b (+http://search.msn.com/msnbot.htm)
    # msnbot/2.0b (+http://search.msn.com/msnbot.htm).
    # msnbot/2.0b (+http://search.msn.com/msnbot.htm)._
    # Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)
    # Pingdom.com_bot_version_1.4_(http://www.pingdom.com/)
    # ia_archiver (+http://www.alexa.com/site/help/webmasters; crawler@alexa.com)
    # Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)
    #
  
    KNOWN_SEARCH_BOTS = [
       GOOGLE_BOT = Regexp.compile('Googlebot.*\/'),
          MSN_BOT = Regexp.compile('msnbot\/'),
        YAHOO_BOT = Regexp.compile('Yahoo! Slurp\/?'),
      PINGDOM_BOT = Regexp.compile('Pingdom.com_bot_version_'),
        ALEXA_BOT = Regexp.compile('ia_archiver'),
       YANDEX_BOT = Regexp.compile('YandexBot\/'),
      nil
    ].compact!

    def self.known_search_bot?(user_agent) !KNOWN_SEARCH_BOTS.detect { |bot| bot.match(user_agent) }.nil? end 
    def      known_search_bot?() self.class.known_search_bot?(self.http_user_agent) ; end

    #
    # mainly to easily identify external referers, for filtering purposes
    #

    INTERNAL_REFERERS = [
      Regexp.compile('^http://(www\.)?MY_WEBSITE_NAME\.com'),
      Regexp.compile('^-$'),
    ]

    def self.internal_referer?(http_referer) !INTERNAL_REFERERS.detect { |referer| referer.match(http_referer) }.nil? end
    def      internal_referer?() self.class.internal_referer?(self.http_referer) ; end

    def self.external_referer?(http_referer) !self.internal_referer?(http_referer) ; end
    def      external_referer?() self.class.external_referer?(self.http_referer) ; end

    def self.authenticated_user?(remote_user) remote_user and remote_user != "-" ; end
    def      authenticated_user?() self.class.authenticated_user?(self.remote_user) ; end

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
