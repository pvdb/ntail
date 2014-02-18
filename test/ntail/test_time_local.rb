require 'helper'

class TestTimeLocal < Test::Unit::TestCase

  context "ntail" do

    setup do
      @time_local = "13/Apr/2010:04:45:51 +0100"
      @log_line = random_log_line(:time_local => @time_local)
    end

    should "parse local time (in the common log format) into a date object" do
      # directly via the helper function
      to_date = NginxTail::LogLine.to_date(@time_local)
      assert_equal "2010-04-13T04:45:51+01:00", to_date.to_s
      # parsed from a raw log line
      assert_equal "2010-04-13T04:45:51+01:00", @log_line.to_date.to_s
    end

    should "parse and format local time (in the common log format) into a date string" do
      # directly via the helper function
      to_date_s = NginxTail::LogLine.to_date_s(@time_local)
      assert_equal "2010-04-13 04:45:51", to_date_s
      # parsed from a raw log line
      assert_equal "2010-04-13 04:45:51", @log_line.to_date_s
    end

  end

end
