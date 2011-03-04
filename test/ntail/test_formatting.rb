require 'helper'

class TestFormatting < Test::Unit::TestCase

  context "NginxTail::Formatting" do
    
    should "correctly format itself using the %a taken" do
      remote_addr = random_ip_address
      log_line = random_log_line(:remote_addr => remote_addr)
      NginxTail::LogLine.format = "%a"
      assert_equal "%15s" % remote_addr, log_line.to_s(:color => false)
    end
     
  end

end
