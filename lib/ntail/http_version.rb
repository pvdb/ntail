module NginxTail
  module HttpVersion
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'http_version'" unless base.instance_methods.include? 'http_version'
        
      end
    end
        
  end
end