require 'helper'

class TestStatus < Test::Unit::TestCase

  context "ntail" do

    should "correctly identify the nginx 499 status code" do
      status = NginxTail::Status::NGINX_MAGIC_STATUS # 499
      # directly via the helper function
      assert !NginxTail::LogLine.information_status?(status)
      assert !NginxTail::LogLine.success_status?(status)
      assert !NginxTail::LogLine.redirect_status?(status)
      assert !NginxTail::LogLine.client_error_status?(status)
      assert !NginxTail::LogLine.server_error_status?(status)
      # parsed from a raw log line
      log_line = random_log_line(:status => NginxTail::Status::NGINX_MAGIC_STATUS)
      assert !log_line.information_status?
      assert !log_line.success_status?
      assert !log_line.redirect_status?
      assert !log_line.client_error_status?
      assert !log_line.server_error_status?
    end

  end

end
