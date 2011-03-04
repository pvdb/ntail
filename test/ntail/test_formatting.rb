require 'helper'

class TestFormatting < Test::Unit::TestCase

  context "NginxTail::Formatting" do
    
    should "correctly format remote_addr using the %a taken" do
      remote_addr = random_ip_address
      log_line = random_log_line(:remote_addr => remote_addr)
      NginxTail::LogLine.format = "%a"
      assert_equal "%15s" % remote_addr, log_line.to_s(:color => false)
    end
     
    should "correctly format remote_user using the %u taken" do
      remote_user = 'me_myself_and_i'
      log_line = random_log_line(:remote_user => remote_user)
      NginxTail::LogLine.format = "%u"
      assert_equal remote_user, log_line.to_s(:color => false)
    end
     
    should "correctly format time_local using the %t taken" do
      time_local = '25/Feb/2011:07:53:29 +0000'
      log_line = random_log_line(:time_local => time_local)
      NginxTail::LogLine.format = "%t"
      assert_equal '2011-02-25 07:53:29', log_line.to_s(:color => false)
    end
     
    should "correctly format request using the %r taken" do
      request = 'GET / HTTP/1.1'
      log_line = random_log_line(:request => request)
      NginxTail::LogLine.format = "%r"
      assert_equal 'GET /', log_line.to_s(:color => false)
    end
     
    should "correctly format status using the %s taken" do
      status = '200'
      log_line = random_log_line(:status => status)
      NginxTail::LogLine.format = "%s"
      assert_equal status, log_line.to_s(:color => false)
    end
     
    should "correctly format body_bytes_sent using the %b taken" do
      body_bytes_sent = '31415'
      log_line = random_log_line(:body_bytes_sent => body_bytes_sent)
      NginxTail::LogLine.format = "%b"
      assert_equal body_bytes_sent, log_line.to_s(:color => false)
    end
     
    should "correctly format http_referer using the %R taken" do
      http_referer = 'http://www.google.com/search?q=ntail'
      log_line = random_log_line(:http_referer => http_referer)
      NginxTail::LogLine.format = "%R"
      assert_equal 'www.google.com', log_line.to_s(:color => false)
    end
     
    should "correctly format http_user_agent using the %U taken" do
      http_user_agent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.102 Safari/534.13'
      log_line = random_log_line(:http_user_agent => http_user_agent)
      NginxTail::LogLine.format = "%U"
      assert_equal '(Chrome, OS X 10.6)', log_line.to_s(:color => false)
    end
     
#     should "correctly format proxy_addresses using the %p taken" do
#       proxy_addresses = '"127.0.0.1"'
#       log_line = random_log_line(:proxy_addresses => proxy_addresses)
#       NginxTail::LogLine.format = "%p"
#       assert_equal proxy_addresses, log_line.to_s(:color => false)
#     end
     
  end

end
