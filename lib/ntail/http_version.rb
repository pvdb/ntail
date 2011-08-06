module NginxTail
  module HttpVersion
    
    def self.included(base) # :nodoc:
      base.class_eval do

        @@http_version_expression = Regexp.compile('HTTP/([0-9])\.([0-9])')

        def self.minor_version(http_version)
          return $1 if http_version =~ @@http_version_expression
        end

        def self.major_version(http_version)
          return $1 if http_version =~ @@http_version_expression
        end

        def self.to_http_version_s(http_version, which = :full)
          # http_version will be nil if $request == "-" (ie. "dodgy" HTTP requests)
          http_version.nil? ? "" : case which
            when :full then http_version
            when :major then self.major_version(http_version)
            when :minor then self.minor_version(http_version)
          end
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_version'" unless base.instance_methods.map(&:to_s).include? 'http_version'
        
      end
    end

    def to_http_version_s(which = :full)
      self.class.to_http_version_s(self.http_version, which)
    end
    
  end
end
