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

        def self.local_ip_address?(remote_address)
          @@local_ip_addresses.include?(remote_address)
        end
        
      end
    end
    
  end
end