module NginxTail
  module HttpVersion
    
    def self.included(base) # :nodoc:
      base.class_eval do

        def self.to_http_version_s(http_version)
          http_version || "" # will be nil if $request == "-" (ie. "dodgy" HTTP requests)
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_version'" unless base.instance_methods.include? 'http_version'
        
      end
    end

    def to_http_version_s
      self.class.to_http_version_s(self.http_version)
    end
    
  end
end
