require 'helper'

class TestVariableConversions < Test::Unit::TestCase

  should "parse local time (in the common log format) into a date" do
    time_local = "13/Apr/2010:04:45:51 +0100"
    to_date = NginxTail::LogLine.to_date(time_local)
    assert_equal "2010-04-13T04:45:51+01:00", to_date.to_s
  end

  should "parse and format local time (in the common log format) into a date string" do
    time_local = "13/Apr/2010:04:45:51 +0100"
    to_date_s = NginxTail::LogLine.to_date_s(time_local)
    assert_equal "2010-04-13 04:45:51", to_date_s
  end

end