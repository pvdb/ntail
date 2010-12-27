require 'helper'

class TestVariableConversions < Test::Unit::TestCase

  should "parse local time (in the common log format) into a date object" do
    time_local = "13/Apr/2010:04:45:51 +0100"
    to_date = NginxTail::LogLine.to_date(time_local)
    assert_equal "2010-04-13T04:45:51+01:00", to_date.to_s

    log_line = random_log_line(:time_local => '19/Dec/2010:05:01:29 +0000')
    assert_equal "2010-12-19T05:01:29+00:00", log_line.to_date.to_s
  end

  should "parse and format local time (in the common log format) into a date string" do
    time_local = "13/Apr/2010:04:45:51 +0100"
    to_date_s = NginxTail::LogLine.to_date_s(time_local)
    assert_equal "2010-04-13 04:45:51", to_date_s

    log_line = random_log_line(:time_local => '16/Jan/2010:04:00:29 +0000')
    assert_equal "2010-01-16 04:00:29", log_line.to_date_s    
  end

end