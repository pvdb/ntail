require 'uri'

module NginxTail
  module HttpReferer

    #
    # to easily identify external referers, for filtering and formatting purposes
    #
    # e.g. Regexp.compile('^http(s)?://(www\.)?MY_WEBSITE_NAME\.com')
    #

    UNKNOWN_REFERER = "-".freeze # the 'default' nginx value for $http_referer variable

    def self.included(base) # :nodoc:
      base.class_eval do

        @@internal_referers = []

        # mainly (solely?) for testing purposes...
        def self.reset_internal_referers()
          while !@@internal_referers.empty? ; @@internal_referers.pop ; end
        end

        # mainly (solely?) for testing purposes...
        def self.internal_referers()
          @@internal_referers.dup
        end

        def self.add_internal_referer(internal_referer)
          raise "Cannot add unkown HTTP referer" if self.unknown_referer? internal_referer
          (@@internal_referers << internal_referer).uniq!
        end

        def self.unknown_referer?(http_referer)
          http_referer == UNKNOWN_REFERER
        end

        def self.internal_referer?(http_referer)
          !self.unknown_referer?(http_referer) && !@@internal_referers.detect { |referer| referer.match(http_referer) }.nil?
        end

        def self.external_referer?(http_referer)
          !self.unknown_referer?(http_referer) && !self.internal_referer?(http_referer)
        end

        def self.to_referer_s(http_referer)
          if self.unknown_referer? http_referer
            http_referer
          else begin
              # try to parse it as a URI, but with default value if un-parsable
              URI.parse(http_referer).host || http_referer
            rescue URI::InvalidURIError
              http_referer
            end
          end
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_referer'" unless base.instance_methods.map(&:to_s).include? 'http_referer'

      end
    end

    def unknown_referer?
      self.class.unknown_referer?(self.http_referer)
    end

    def internal_referer?
      self.class.internal_referer?(self.http_referer)
    end

    def external_referer?
      self.class.external_referer?(self.http_referer)
    end

    def to_referer_s
      self.class.to_referer_s(self.http_referer)
    end

  end
end
