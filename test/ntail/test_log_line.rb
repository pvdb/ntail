require 'helper'

class TestLogLine < Test::Unit::TestCase

  context "NginxTail::LogLine" do
    
    should "initialize itself correctly from a parsable log line" do
      raw_line = random_raw_line
      log_line = NginxTail::LogLine.new(raw_line)
      assert_equal raw_line, log_line.raw_line
      assert log_line.parsable
    end
    
    should "initialize itself correctly from a non-parsable log line" do
      raw_line = "foo bar blegga"
      log_line = NginxTail::LogLine.new(raw_line)
      assert_equal raw_line, log_line.raw_line
      assert !log_line.parsable
    end
    
    
    should "implement non-abbreviated alias for $remote_addr" do
      remote_addr = random_ip_address
      log_line = random_log_line(:remote_addr => remote_addr)
      assert_equal remote_addr, log_line.remote_addr
      assert_equal remote_addr, log_line.remote_address
    end
    
    should "implement attr_reader for each (sub-)component" do
      (NginxTail::LogLine::COMPONENTS + NginxTail::LogLine::SUBCOMPONENTS).each do |component|
        assert NginxTail::LogLine.instance_methods.include?(component.to_s), "getter '#{component}' should exist"
      end
    end

    should "NOT implement attr_writer for any (sub-)component" do
      (NginxTail::LogLine::COMPONENTS + NginxTail::LogLine::SUBCOMPONENTS).each do |component|
        assert !NginxTail::LogLine.instance_methods.include?(component.to_s + "="), "setter '#{component.to_s + "="}' should NOT exist"
      end
    end
      
  end

end