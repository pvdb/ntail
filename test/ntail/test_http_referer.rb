require 'helper'

class TestHttpReferer < Test::Unit::TestCase

  def teardown
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
    refering_page = "http://my_website.com/index.html"
    log_line = random_log_line(:http_referer => refering_page)

    assert !NginxTail::LogLine.internal_referer?(refering_page)
    assert NginxTail::LogLine.external_referer?(refering_page)
    assert !log_line.internal_referer?
    assert log_line.external_referer?
    
    NginxTail::LogLine.add_internal_referer(/http:\/\/my_website\.com/)
    assert NginxTail::LogLine.internal_referer?(refering_page)
    assert !NginxTail::LogLine.external_referer?(refering_page)
    assert log_line.internal_referer?
    assert !log_line.external_referer?
  end

end
