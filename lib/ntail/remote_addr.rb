require 'socket'

module NginxTail
  module RemoteAddr

    def self.included(base) # :nodoc:
      base.class_eval do

        def self.to_host_s(remote_addr)
          Socket::getaddrinfo(remote_addr, nil)[0][2]
        end
        
        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'remote_addr'" unless base.instance_methods.include? 'remote_addr'

      end
    end

    def to_host_s()
      self.class.to_host_s(self.remote_addr)
    end
    
  end
end