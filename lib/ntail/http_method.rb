module NginxTail
  module HttpMethod
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_method'" unless base.instance_methods.include? 'http_method'
        
      end
    end
        
  end
end