module NginxTail
  module HttpUserAgent
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_user_agent'" unless base.instance_methods.include? 'http_user_agent'
        
      end
    end
        
  end
end