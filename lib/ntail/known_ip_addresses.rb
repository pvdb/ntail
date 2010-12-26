module NginxTail
  module KnownIpAddresses

    #
    # known IP addresses, for filtering and formatting purposes
    #
    # e.g. office IP addresses, IP addresses of remote workers, ...
    #

    def self.included(base) # :nodoc:
      base.class_eval do
    
        @@known_ip_addresses = []

        # mainly (solely?) for testing purposes...
        def self.known_ip_addresses()
          @@known_ip_addresses.dup
        end
        
        # mainly (solely?) for testing purposes...
        def self.reset_known_ip_addresses()
          while !@@known_ip_addresses.empty? ; @@known_ip_addresses.pop ; end
        end
        
        def self.add_known_ip_address(known_ip_address)
          (@@known_ip_addresses << known_ip_address).uniq!
        end

        def self.known_ip_address?(remote_address)
          @@known_ip_addresses.include?(remote_address)
        end
        
      end
    end
    
  end
end