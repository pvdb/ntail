module NginxTail
  module LocalIpAddresses
    
    #
    # local IP addresses, for filtering and formatting purposes
    #
    # e.g. downstream proxy servers (nginx web servers -> passenger app servers)
    #

    def self.included(base) # :nodoc:
      base.class_eval do

        @@local_ip_addresses = []
        
        # mainly (solely?) for testing purposes...
        def self.local_ip_addresses()
          @@local_ip_addresses.dup
        end
        
        # mainly (solely?) for testing purposes...
        def self.reset_local_ip_addresses()
          while !@@local_ip_addresses.empty? ; @@local_ip_addresses.pop ; end
        end
        
        def self.add_local_ip_address(local_ip_address)
          (@@local_ip_addresses << local_ip_address).uniq!
        end

        def self.local_ip_address?(remote_addr)
          @@local_ip_addresses.include?(remote_addr)
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'remote_addr'" unless base.instance_methods.map(&:to_s).include? 'remote_addr'
        
      end
    end
    
    def local_ip_address?
      self.class.local_ip_address?(self.remote_addr)
    end
    
  end
end
