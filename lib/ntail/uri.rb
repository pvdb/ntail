module NginxTail
  module Uri
    
    def self.included(base) # :nodoc:
      base.class_eval do

        def self.to_uri_s(uri)
          uri || "-" # will be nil if $request == "-" (ie. "dodgy" HTTP requests)
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'uri'" unless base.instance_methods.include? 'uri'
        
      end
    end
    
    def to_uri_s
      self.class.to_uri_s(self.uri)
    end
    
  end
end
