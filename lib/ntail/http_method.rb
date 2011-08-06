module NginxTail
  module HttpMethod
    
    #
    # http://www.ietf.org/rfc/rfc2616.txt - "section 5.1.1 Method"
    # 
    # OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT 
    #
    
    def self.included(base) # :nodoc:
      base.class_eval do
        
        def self.to_http_method_s(http_method)
          (http_method ||= "").upcase!  # will be nil if $request == "-" (ie. "dodgy" HTTP requests)
          case http_method
          when "POST", "PUT", "DELETE"
            http_method.inverse # if Sickill::Rainbow.enabled...
          else
            http_method
          end
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_method'" unless base.instance_methods.map(&:to_s).include? 'http_method'
        
      end
    end
    
    def to_http_method_s
      self.class.to_http_method_s(self.http_method)
    end
    
  end
end
