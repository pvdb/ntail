require 'helper'

class TestHttpReferer < Test::Unit::TestCase

  context "ntail" do
    
    setup do
      @http_referer = "http://example.com/index.html"
      @log_line = random_log_line(:http_referer => @http_referer)
    end
    
    teardown do
      # undo any changes the test may have made
      NginxTail::LogLine.reset_internal_referers
    end
    
    should "have empty list of internal referers without configuration" do
      assert NginxTail::LogLine.internal_referers.empty?
    end

    should "correctly identify the default/unknown HTTP referer" do
      unknown_referer = NginxTail::HttpReferer::UNKNOWN_REFERER
      log_line = random_log_line(:http_referer => unknown_referer)

      assert NginxTail::LogLine.unknown_referer?(unknown_referer)
      assert !NginxTail::LogLine.internal_referer?(unknown_referer)
      assert !NginxTail::LogLine.external_referer?(unknown_referer)

      assert log_line.unknown_referer?
    end

    should "not allow the default/unknown HTTP referer to be added" do
      assert_raise RuntimeError do
        NginxTail::LogLine.add_internal_referer(NginxTail::HttpReferer::UNKNOWN_REFERER)
      end
    end

    should "have non-empty list of internal referers after configuration" do
      NginxTail::LogLine.add_internal_referer(first_referer = /http:\/\/my_website\.com/)
      assert_equal 1, NginxTail::LogLine.internal_referers.size
      assert NginxTail::LogLine.internal_referers.include?(first_referer)

      NginxTail::LogLine.add_internal_referer(second_referer = /http:\/\/www.my_website\.com/)
      assert_equal 2, NginxTail::LogLine.internal_referers.size
      assert NginxTail::LogLine.internal_referers.include?(second_referer)
    end

    should "recognize an internal referer after configuration" do
      assert !NginxTail::LogLine.internal_referer?(@http_referer)
      assert NginxTail::LogLine.external_referer?(@http_referer)
      assert !@log_line.internal_referer?
      assert @log_line.external_referer?

      NginxTail::LogLine.add_internal_referer(/http:\/\/example\.com/)
      
      assert NginxTail::LogLine.internal_referer?(@http_referer)
      assert !NginxTail::LogLine.external_referer?(@http_referer)
      assert @log_line.internal_referer?
      assert !@log_line.external_referer?
    end
    
    should "parse and format the unknownHTTP referer" do
      http_referer = NginxTail::HttpReferer::UNKNOWN_REFERER
      assert_equal http_referer, NginxTail::LogLine.to_referer_s(http_referer)
    end

    should "parse and format HTTP referer into a host string" do
      # directly via the helper function
      to_referer_s = NginxTail::LogLine.to_referer_s(@http_referer)
      assert_equal "example.com", to_referer_s
      # parsed from a raw log line
      assert_equal "example.com", @log_line.to_referer_s    
    end
    
  end

end
