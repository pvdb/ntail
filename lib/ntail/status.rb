module NginxTail
  module Status
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'status'" unless base.instance_methods.include? 'status'
        
      end
    end
        
  end
end