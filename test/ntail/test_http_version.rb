require 'helper'

class TestHttpVersion < Test::Unit::TestCase

  context "ntail" do

    should "correctly identify the HTTP version of the request" do
      http_version = "HTTP/1.0"
      # directly via the helper function
      assert_equal http_version, NginxTail::LogLine.to_http_version_s(http_version)
      # parsed from a raw log line
      log_line = random_log_line(:http_version => http_version)
      assert_equal http_version, log_line.to_http_version_s
    end

    should "correctly identify the major HTTP version" do
      http_version = "HTTP/1.0"
      # directly via the helper function
      assert_equal "1", NginxTail::LogLine.to_http_version_s(http_version, :major)
      # parsed from a raw log line
      log_line = random_log_line(:http_version => http_version)
      assert_equal "1", log_line.to_http_version_s(:major)
    end

    should "correctly identify the minor HTTP version" do
      http_version = "HTTP/1.0"
      # directly via the helper function
      assert_equal "1", NginxTail::LogLine.to_http_version_s(http_version, :minor)
      # parsed from a raw log line
      log_line = random_log_line(:http_version => http_version)
      assert_equal "1", log_line.to_http_version_s(:minor)
    end

  end

end
