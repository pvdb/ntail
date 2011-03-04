require 'helper'

class TestRemoteAddr < Test::Unit::TestCase

  context "ntail" do
    
    setup do
      @remote_addr = "192.0.32.10"
      @log_line = random_log_line(:remote_addr => @remote_addr)
    end

    #
    # Note on the assertions in this unit test, which should read:
    #
    # assert_equal "www.example.com", to_host_s
    # assert_equal "www.example.com", @log_line.to_host_s
    #
    # However, when the tests are run
    # when not connected to a network
    # the DNS lookup will fail, and:
    #
    # "192.0.32.10" => "192.0.32.10"
    #
    # instead of:
    #
    # "192.0.32.10" => "example.com"
    #
    # We could fix this by adding the corresponding entry to the
    # local /etc/hosts file, or (arguably  :-) with some mocking
    #

    should "convert the request's remote address into a host string" do
      # directly via the helper function
      to_host_s = NginxTail::LogLine.to_host_s(@remote_addr)
      assert ["www.example.com", "192.0.32.10"].include? to_host_s
      # parsed from a raw log line
      assert ["www.example.com", "192.0.32.10"].include? @log_line.to_host_s
    end
    
    should "convert the request's remote address into a country string" do
      return unless File.exists?('/usr/share/GeoIP/GeoIP.dat')
      # directly via the helper function
      to_country_s = NginxTail::LogLine.to_country_s(@remote_addr)
      assert_equal "United States", to_country_s
      # parsed from a raw log line
      assert_equal "United States", @log_line.to_country_s
    end
    
    should "convert the request's remote address into a city string" do
      return unless File.exists?('/usr/share/GeoIP/GeoIPCity.dat')
      # directly via the helper function
      to_city_s = NginxTail::LogLine.to_city_s(@remote_addr)
      assert_equal "Marina Del Rey", to_city_s
      # parsed from a raw log line
      assert_equal "Marina Del Rey", @log_line.to_city_s
    end
    
  end

end
