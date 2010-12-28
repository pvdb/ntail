module NginxTail
  module ProxyAddresses
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'proxy_addresses'" unless base.instance_methods.include? 'proxy_addresses'
        
      end
    end
        
  end
end