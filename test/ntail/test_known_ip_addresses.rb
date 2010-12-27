require 'helper'

class TestKnownIpAddresses < Test::Unit::TestCase

  def teardown
    # undo any changes the test may have made
    NginxTail::LogLine.reset_known_ip_addresses
  end

  should "have empty list of known IP addresses without configuration" do
    assert NginxTail::LogLine.known_ip_addresses.empty?
  end

  should "have non-empty list of known IP addresses after configuration" do
    NginxTail::LogLine.add_known_ip_address(first_ip_address = random_ip_address)
    assert_equal 1, NginxTail::LogLine.known_ip_addresses.size
    assert NginxTail::LogLine.known_ip_addresses.include?(first_ip_address)
    
    NginxTail::LogLine.add_known_ip_address(second_ip_address = random_ip_address)
    assert_equal 2, NginxTail::LogLine.known_ip_addresses.size
    assert NginxTail::LogLine.known_ip_addresses.include?(second_ip_address)
  end

  should "avoid duplicates in list of known IP addresses" do
    NginxTail::LogLine.add_known_ip_address(known_ip_address = random_ip_address)
    assert_equal 1, NginxTail::LogLine.known_ip_addresses.size
    
    NginxTail::LogLine.add_known_ip_address(known_ip_address)
    assert_equal 1, NginxTail::LogLine.known_ip_addresses.size
  end
  
  should "recognize a known IP address after configuration" do
    remote_address = random_ip_address
    log_line = random_log_line(:remote_addr => remote_address)
    
    assert !NginxTail::LogLine.known_ip_address?(remote_address)
    assert !log_line.known_ip_address?
    
    NginxTail::LogLine.add_known_ip_address(remote_address)
    
    assert NginxTail::LogLine.known_ip_address?(remote_address)
    assert log_line.known_ip_address?
  end

end
