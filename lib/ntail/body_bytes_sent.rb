module NginxTail
  module BodyBytesSent
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'body_bytes_sent'" unless base.instance_methods.include? 'body_bytes_sent'
        
      end
    end
        
  end
end