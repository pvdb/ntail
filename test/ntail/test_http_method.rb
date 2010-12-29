require 'helper'

class TestHttpMethod < Test::Unit::TestCase

  context "ntail" do
    
    context "(with Sickill::Rainbow enabled)" do
      
      setup do
        Sickill::Rainbow.enabled = true
      end
    
      should "color-code the HTTP method" do
        
        # read-only methods are never color-coded...
        log_line = random_log_line(:http_method => 'GET')
        assert_equal "GET", log_line.to_http_method_s
        
        # methods that change state are ALWAYS color-coded if Rainbow is enabled... 
        log_line = random_log_line(:http_method => 'POST')
        assert_not_equal "POST", log_line.to_http_method_s
        assert_equal "POST".inverse, log_line.to_http_method_s
        
      end
      
    end
    
    context "(with Sickill::Rainbow disabled)" do

      setup do
        Sickill::Rainbow.enabled = false
      end
    
      should "NOT color-code the HTTP method" do
        
        # read-only methods are never color-coded...
        log_line = random_log_line(:http_method => 'GET')
        assert_equal "GET", log_line.to_http_method_s
        
        # methods that change state are NOT color-coded if Rainbow is disabled...
        log_line = random_log_line(:http_method => 'POST')
        assert_equal "POST", log_line.to_http_method_s
        
      end
      
    end
    
  end

end