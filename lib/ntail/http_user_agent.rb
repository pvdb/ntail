require 'rubygems'
require 'user-agent'

class Agent
  
  def search_bot?
    false
  end

end

class SearchBot < Agent

  def search_bot?
    true
  end
  
  #
  # Feedfetcher-Google; (+http://www.google.com/feedfetcher.html; feed-id=17168503030479467473)
  # Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
  # Googlebot-Image/1.0
  # msnbot/2.0b (+http://search.msn.com/msnbot.htm)
  # msnbot/2.0b (+http://search.msn.com/msnbot.htm).
  # msnbot/2.0b (+http://search.msn.com/msnbot.htm)._
  # Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)
  # Pingdom.com_bot_version_1.4_(http://www.pingdom.com/)
  # ia_archiver (+http://www.alexa.com/site/help/webmasters; crawler@alexa.com)
  # Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)
  # Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
  #

  KNOWN_SEARCH_BOTS = [
     GOOGLE_RSS = Regexp.compile('Feedfetcher-Google.*\/'),
     GOOGLE_BOT = Regexp.compile('Googlebot.*\/'),
        MSN_BOT = Regexp.compile('msnbot\/'),
      YAHOO_BOT = Regexp.compile('Yahoo! Slurp\/?'),
    PINGDOM_BOT = Regexp.compile('Pingdom.com_bot_version_'),
      ALEXA_BOT = Regexp.compile('ia_archiver'),
     YANDEX_BOT = Regexp.compile('YandexBot\/'),
       BING_BOT = Regexp.compile('bingbot\/'),
  ]

  def self.search_bot?(http_user_agent)
    !KNOWN_SEARCH_BOTS.detect { |bot| bot.match(http_user_agent) }.nil?
  end 
  
  attr_accessor :name
  attr_accessor :os

  def initialize(string)
    super string
    @name = self.class.name_for_user_agent(string)
    @os = self.class.os_for_user_agent(string)
  end

  def self.name_for_user_agent string
    case string
      when  GOOGLE_BOT then :googlebot
      when     MSN_BOT then :msnbot
      when   YAHOO_BOT then :yahoo_slurp
      when   ALEXA_BOT then :ia_archiver
      when PINGDOM_BOT then :pingdom_bot
      when  YANDEX_BOT then :yandex_bot
      when    BING_BOT then :bingbot
      else super(string)
    end
  end
  
  def self.os_for_user_agent string
    case string
      when  GOOGLE_BOT then :"google.com"
      when     MSN_BOT then :"msn.com"
      when   YAHOO_BOT then :"yahoo.com"
      when   ALEXA_BOT then :"alexa.com"
      when PINGDOM_BOT then :"pingdom.com"
      when  YANDEX_BOT then :"yandex.com"
      when    BING_BOT then :"bing.com"
      else super(string)
    end
  end
  
end

module NginxTail
  module HttpUserAgent
    
    def self.included(base) # :nodoc:
      base.class_eval do

        def self.search_bot?(http_user_agent)
          SearchBot.search_bot?(http_user_agent)
        end 

        def self.to_agent(http_user_agent)
          if self.search_bot? http_user_agent
            SearchBot.new(http_user_agent)
          else
            Agent.new(http_user_agent)
          end
        end

        def self.to_agent_s(http_user_agent)
          agent = self.to_agent http_user_agent
          "(%s, %s)" % [agent.name, agent.os]
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_user_agent'" unless base.instance_methods.map(&:to_s).include? 'http_user_agent'
        
      end
    end
    
    def search_bot?
      self.class.search_bot?(self.http_user_agent)
    end
    
    def to_agent
      self.class.to_agent(self.http_user_agent)
    end
    
    def to_agent_s
      self.class.to_agent_s(self.http_user_agent)
    end
    
  end
end


