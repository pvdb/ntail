require 'helper'

class TestNtail < Test::Unit::TestCase

  should "have namespaced classes" do
    assert_equal "constant", defined? NginxTail
    assert NginxTail.is_a? Module
    
    assert_equal "constant", defined? NginxTail::LogLine
    assert NginxTail::LogLine.is_a? Class
    
    assert_equal "constant", defined? NginxTail::Application
    assert NginxTail::Application.is_a? Class
  end

  should "have namespaced modules" do
    assert_equal "constant", defined? NginxTail::Inflections
    assert NginxTail::Inflections.is_a? Module
  end

end
