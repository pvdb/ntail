require 'rubygems'
require 'bundler'

require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'ntail'

def stfu # "shut the f*ck up", in case you're wondering :-)
  begin
    orig_stderr = $stderr.clone
    orig_stdout = $stdout.clone
    $stderr.reopen File.new('/dev/null', 'w')
    $stdout.reopen File.new('/dev/null', 'w')
    return_value = yield
  rescue
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
    raise $!
  ensure
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
  end
  return_value
end
