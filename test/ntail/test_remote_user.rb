require 'helper'

class TestRemoteUser < Test::Unit::TestCase

  def teardown
    # undo any changes the test may have made
    NginxTail::LogLine.reset_authenticated_users
  end

  should "have empty list of authenticated users without configuration" do
    assert NginxTail::LogLine.authenticated_users.empty?
  end
  
  should "correctly identify the default/unknown remote user" do
    unknown_remote_user = NginxTail::RemoteUser::UNKNOWN_REMOTE_USER
    log_line = random_log_line(:remote_user => unknown_remote_user)
    
    assert NginxTail::LogLine.unknown_remote_user?(unknown_remote_user)
    assert !NginxTail::LogLine.remote_user?(unknown_remote_user)
    assert !NginxTail::LogLine.authenticated_user?(unknown_remote_user)
    
    assert log_line.unknown_remote_user?
  end
  
  should "not allow the default/unknown remote user to be added" do
    assert_raise RuntimeError do
      NginxTail::LogLine.add_authenticated_user(NginxTail::RemoteUser::UNKNOWN_REMOTE_USER)
    end
  end

  should "have non-empty list of authenticated users after configuration" do
    NginxTail::LogLine.add_authenticated_user(first_remote_user = "john_doe")
    assert_equal 1, NginxTail::LogLine.authenticated_users.size
    assert NginxTail::LogLine.authenticated_users.include?(first_remote_user)
    
    NginxTail::LogLine.add_authenticated_user(second_referer = "jane_doe")
    assert_equal 2, NginxTail::LogLine.authenticated_users.size
    assert NginxTail::LogLine.authenticated_users.include?(second_referer)
  end

  should "avoid duplicates in list of authenticated users" do
    NginxTail::LogLine.add_authenticated_user(authenticated_user = "john_doe")
    assert_equal 1, NginxTail::LogLine.authenticated_users.size
    
    NginxTail::LogLine.add_authenticated_user(authenticated_user)
    assert_equal 1, NginxTail::LogLine.authenticated_users.size
  end

  should "recognize a remote user after configuration" do
    remote_user = "john_doe"
    log_line = random_log_line(:remote_user => remote_user)

    assert NginxTail::LogLine.remote_user?(remote_user)
    assert !NginxTail::LogLine.authenticated_user?(remote_user)
    assert log_line.remote_user?
    assert !log_line.authenticated_user?
    
    NginxTail::LogLine.add_authenticated_user(remote_user)
    assert NginxTail::LogLine.remote_user?(remote_user)
    assert NginxTail::LogLine.authenticated_user?(remote_user)
    assert log_line.remote_user?
    assert log_line.authenticated_user?
  end

end
