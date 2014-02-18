module NginxTail
  module Request

    UNKNOWN_REQUEST = "-".freeze # the 'default' nginx value for $request variable

    def self.included(base) # :nodoc:
      base.class_eval do

        def self.unknown_request?(request)
          request == UNKNOWN_REQUEST
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'request'" unless base.instance_methods.map(&:to_s).include? 'request'

      end
    end

    def unknown_request?
      self.class.unknown_request?(self.request)
    end

    def to_request_s
      if self.unknown_request?
        self.request
      else
        # note: we exclude the HTTP version info...
        "%s %s" % [self.to_http_method_s, self.to_uri_s]
      end
    end

  end
end
