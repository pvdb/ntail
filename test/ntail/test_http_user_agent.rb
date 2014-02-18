require 'helper'

class TestHttpUserAgent < Test::Unit::TestCase

  context "ntail" do

    should "correctly identify search bot user agent" do
      search_bot_user_agent = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
      # directly via the helper function
      assert NginxTail::LogLine.search_bot?(search_bot_user_agent)
      # parsed from a raw log line
      log_line = random_log_line(:http_user_agent => search_bot_user_agent)
      assert log_line.search_bot?
      assert log_line.to_agent.search_bot?
    end

    should "correctly identify non-bot user agent" do
      non_bot_user_agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
      # directly via the helper function
      assert !NginxTail::LogLine.search_bot?(non_bot_user_agent)
      # parsed from a raw log line
      log_line = random_log_line(:http_user_agent => non_bot_user_agent)
      assert !log_line.search_bot?
      assert !log_line.to_agent.search_bot?
    end

  end

end
