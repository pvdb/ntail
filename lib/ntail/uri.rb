module NginxTail
  module Uri
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'uri'" unless base.instance_methods.include? 'uri'
        
      end
    end
        
  end
end