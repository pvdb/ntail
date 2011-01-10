require 'helper'

class TestUri < Test::Unit::TestCase

  context "ntail" do

    teardown do
      # undo any changes the test may have made
      NginxTail::LogLine.reset_automatic_files
    end
    
    should "correctly identify a default automatic request" do
      # directly via the helper function
      # parsed from a raw log line
      log_line = random_log_line(:uri => '/index.html')
      assert !log_line.automatic_uri?      
      log_line = random_log_line(:uri => '/robots.txt')
      assert log_line.automatic_uri?      
    end

    should "correctly identify a custom automatic request" do
      # directly via the helper function
      # parsed from a raw log line
      log_line = random_log_line(:uri => '/blegga.html')
      assert !log_line.automatic_uri?
      NginxTail::LogLine.add_automatic_file('blegga.html')
      assert log_line.automatic_uri? 
    end
        
  end

end