require 'helper'

class TestRequest < Test::Unit::TestCase

  context "ntail" do

    should "do something reasonable for bad requests" do

      log_line = bad_request_log_line
      assert_equal "-", log_line.request

      assert_nil log_line.http_method
      assert_nil log_line.uri
      assert_nil log_line.http_version

      assert_equal "", log_line.to_http_method_s
      assert_equal "-", log_line.to_uri_s
      assert_equal "", log_line.to_http_version_s

      assert_equal "-", log_line.to_request_s

    end

  end

end
