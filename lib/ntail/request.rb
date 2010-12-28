module NginxTail
  module Request
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'request'" unless base.instance_methods.include? 'request'
        
      end
    end
        
  end
end