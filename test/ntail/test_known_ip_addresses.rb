require 'helper'

class TestKnownIpAddresses < Test::Unit::TestCase

  def teardown
    # undo any changes the test may have made
    NginxTail::LogLine.reset_known_ip_addresses
  end

  should "have empty list of known IP addresses without configuration" do
    assert NginxTail::LogLine::KNOWN_IP_ADDRESSES.empty?
  end

  should "have non-empty list of known IP addresses after configuration" do
    NginxTail::LogLine.add_known_ip_address(first_ip_address = random_ip_address)
    assert_equal 1, NginxTail::LogLine::KNOWN_IP_ADDRESSES.size
    assert NginxTail::LogLine::KNOWN_IP_ADDRESSES.include?(first_ip_address)
    
    NginxTail::LogLine.add_known_ip_address(second_ip_address = random_ip_address)
    assert_equal 2, NginxTail::LogLine::KNOWN_IP_ADDRESSES.size
    assert NginxTail::LogLine::KNOWN_IP_ADDRESSES.include?(second_ip_address)
  end

  should "avoid duplicates in list of known IP addresses" do
    NginxTail::LogLine.add_known_ip_address(known_ip_address = random_ip_address)
    assert_equal 1, NginxTail::LogLine::KNOWN_IP_ADDRESSES.size
    
    NginxTail::LogLine.add_known_ip_address(known_ip_address)
    assert_equal 1, NginxTail::LogLine::KNOWN_IP_ADDRESSES.size
  end
  
  should "recognize a known IP address after configuration" do
    remote_address = random_ip_address
    assert !NginxTail::LogLine.known_ip_address?(remote_address)
    NginxTail::LogLine.add_known_ip_address(remote_address)
    assert NginxTail::LogLine.known_ip_address?(remote_address)
  end

end
