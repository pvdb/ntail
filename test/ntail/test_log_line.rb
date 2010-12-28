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
    
    should "implement a getter method for each (sub-)component" do
      (NginxTail::LogLine::COMPONENTS + NginxTail::LogLine::SUBCOMPONENTS).each do |component|
        getter_method = component.to_s
        assert NginxTail::LogLine.instance_methods.include?(getter_method), "getter '#{getter_method}' should exist"
      end
    end

    should "NOT implement a setter method for any (sub-)component" do
      (NginxTail::LogLine::COMPONENTS + NginxTail::LogLine::SUBCOMPONENTS).each do |component|
        setter_method = component.to_s + "="
        assert !NginxTail::LogLine.instance_methods.include?(setter_method), "setter '#{setter_method}' should NOT exist"
      end
    end
    
    should "include an extension module for each (sub-)component" do
      (NginxTail::LogLine::COMPONENTS + NginxTail::LogLine::SUBCOMPONENTS).each do |component|
        ntail_module = NginxTail::LogLine.component_to_ntail_module(component)
        assert NginxTail::LogLine.included_modules.include?(ntail_module), "module '#{ntail_module.name}' should be included"
      end
    end
      
  end

end