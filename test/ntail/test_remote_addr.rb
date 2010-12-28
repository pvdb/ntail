require 'helper'

class TestRemoteAddr < Test::Unit::TestCase

  context "ntail" do
    
    setup do
      @remote_addr = "192.0.32.10"
      @log_line = random_log_line(:remote_addr => @remote_addr)
    end

    should "convert the request's remote address into a host string" do
      # directly via the helper function
      to_host_s = NginxTail::LogLine.to_host_s(@remote_addr)
      assert_equal "www.example.com", to_host_s
      # parsed from a raw log line
      assert_equal "www.example.com", @log_line.to_host_s    
    end
    
    should "convert the request's remote address into a country string" do
      # directly via the helper function
      to_country_s = NginxTail::LogLine.to_country_s(@remote_addr)
      assert_equal "United States", to_country_s
      # parsed from a raw log line
      assert_equal "United States", @log_line.to_country_s
    end
    
    should "convert the request's remote address into a city string" do
      # directly via the helper function
      to_city_s = NginxTail::LogLine.to_city_s(@remote_addr)
      assert_equal "Marina Del Rey", to_city_s
      # parsed from a raw log line
      assert_equal "Marina Del Rey", @log_line.to_city_s
    end
    
  end

end