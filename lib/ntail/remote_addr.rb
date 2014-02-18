require 'socket'

begin
  require 'geoip'
rescue LoadError
  # NOOP (optional dependency)
end

module NginxTail
  module RemoteAddr

    def self.included(base) # :nodoc:
      base.class_eval do

        def self.to_host_s(remote_addr)
          Socket::getaddrinfo(remote_addr, nil)[0][2]
        end

        def self.to_country_s(remote_addr)
          record = if defined? GeoIP # ie. if the optional GeoIP gem is installed
            if File.exists?('/usr/share/GeoIP/GeoIP.dat') # ie. if the GeoIP country database is installed
              GeoIP.new('/usr/share/GeoIP/GeoIP.dat').country(remote_addr)
            end
          end
          record ? record[5] : 'N/A'
        end

        def self.to_city_s(remote_addr)
          record = if defined? GeoIP # ie. if the optional GeoIP gem is installed
            if File.exists?('/usr/share/GeoIP/GeoIPCity.dat') # ie. if the GeoIP city database is installed
              GeoIP.new('/usr/share/GeoIP/GeoIPCity.dat').city(remote_addr)
            end
          end
          record ? record[7] : 'N/A'
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'remote_addr'" unless base.instance_methods.map(&:to_s).include? 'remote_addr'

      end
    end

    def to_host_s()
      self.class.to_host_s(self.remote_addr)
    end

    def to_country_s()
      self.class.to_country_s(self.remote_addr)
    end

    def to_city_s()
      self.class.to_city_s(self.remote_addr)
    end

  end
end
