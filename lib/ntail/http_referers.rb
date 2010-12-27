module NginxTail
  module HttpReferers

    #
    # to easily identify external referers, for filtering and formatting purposes
    #
    # e.g. Regexp.compile('^http(s)?://(www\.)?MY_WEBSITE_NAME\.com')
    #

    def self.included(base) # :nodoc:
      base.class_eval do

        @@internal_referers = []

        # mainly (solely?) for testing purposes...
        def self.reset_internal_referers() while !@@internal_referers.empty? ; @@internal_referers.pop ; end ; end
        def self.internal_referers() @@internal_referers.dup ; end
        def self.add_internal_referer(internal_referer) (@@internal_referers << internal_referer).uniq! ; end

        def self.unknown_referer?(http_referer)  http_referer == "-" ; end
        def self.internal_referer?(http_referer) !self.unknown_referer?(http_referer) && !@@internal_referers.detect { |referer| referer.match(http_referer) }.nil? ; end
        def self.external_referer?(http_referer) !self.unknown_referer?(http_referer) && !self.internal_referer?(http_referer) ; end

      end
    end

  end
end