require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'ntail'

class Test::Unit::TestCase

  def random_ip_address
    ((1..4).map { Kernel.rand(256) }).join('.')
  end
  
  def local_ip_address
    # http://en.wikipedia.org/wiki/IP_address#IPv4_private_addresses
    (['192', '168'] + (1..2).map { Kernel.rand(256) }).join('.')
  end

  # 
  # http://wiki.nginx.org/NginxHttpLogModule#log_format
  #
  # There is a predefined log format called "combined":
  # 
  # log_format combined '$remote_addr - $remote_user [$time_local] '
  #                     '"$request" $status $body_bytes_sent '
  #                     '"$http_referer" "$http_user_agent"';
  # 

  LOG_FORMAT_COMBINED = '%s - %s [%s] ' \
                        '"%s" %d %d ' \
                        '"%s" "%s"'
                        
  DEFAULT_VALUES = {
    :remote_addr => '72.46.130.42',
    :remote_user => '-',
    :time_local => '01/Jan/2010:04:00:29 +0000',
    # :request => 'GET /index.html HTTP/1.1',
      :http_method => 'GET',
      :uri => '/index.html',
      :http_version => 'HTTP/1.1',
    :status => 200,
    :body_bytes_sent => 6918,
    :http_referer => 'http://www.google.com/search?q=example',
    :http_user_agent => 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.224 Safari/534.10',
    :proxy_addresses => nil
  }
  
  REQUEST_FORMAT = '%s %s %s'
  
  def random_raw_line(options = {})
    options = DEFAULT_VALUES.merge options
    options[:request] ||= REQUEST_FORMAT % [
      options[:http_method],
      options[:uri],
      options[:http_version]
    ]
    LOG_FORMAT_COMBINED % [
      options[:remote_addr],
      options[:remote_user],
      options[:time_local],
      options[:request],
      options[:status],
      options[:body_bytes_sent],
      options[:http_referer],
      options[:http_user_agent],
      # TODO implement support for :proxy_addresses
    ]
  end
  
  def random_log_line(options = {})
    NginxTail::LogLine.new(random_raw_line(options))
  end
  
  def bad_request_raw_line
    # a "bad request", resulting in a 400 status, is logged by nginx as follows:
    # 121.8.101.138 - - [28/Dec/2010:23:50:58 +0000] "-" 400 0 "-" "-"
    '121.8.101.138 - - [28/Dec/2010:23:50:58 +0000] "-" 400 0 "-" "-"'
  end
  
  def bad_request_log_line
    NginxTail::LogLine.new(bad_request_raw_line)
  end
  
end
