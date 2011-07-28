require 'ostruct'
require 'optparse'

module NginxTail
  class Application
    
    include NginxTail::Options
    
    # default application options...
    DEFAULT_OPTIONS = {
      :interrupted => false,
      :running => true,
      :exit => 0
    }
    
    # parsed application options...
    @options = nil
    
    def respond_to?(symbol, include_private = false)
      @options.respond_to?(symbol) || super
    end

    def method_missing(methodId)
      respond_to?(methodId) ? @options.send(methodId.to_sym) : super
    end

    def initialize(argv = [])
      @options = parse_options(argv, DEFAULT_OPTIONS)
    end
    
    def run!
            
      ['TERM', 'INT'].each do |signal|
        Signal.trap(signal) do
          @options.running = false ; @options.interrupted = true
          $stdin.close if ARGF.file == $stdin # ie. reading from STDIN
        end
      end
      
      files_read = lines_read = lines_processed = lines_ignored = parsable_lines = unparsable_lines = 0
      
      while @options.running and ARGF.gets
        if ARGF.file.lineno == 1
          files_read += 1
          if @options.verbose
            $stderr.puts "[INFO] now processing file #{ARGF.filename}"
          end
        end
        raw_line = $_.chomp ; lines_read += 1
        unless @options.dry_run
          if !@options.line_number or @options.line_number == ARGF.lineno
            begin
              log_line = NginxTail::LogLine.new(raw_line)
              if log_line.parsable
                parsable_lines += 1
                unless @options.parse_only
                  if !@options.filter || @options.filter.call(log_line)
                    lines_processed += 1
                    if @options.code
                      @options.code.call(log_line)
                    elsif @options.raw
                      $stdout.puts raw_line
                      sleep @options.sleep if @options.sleep
                    else
                      puts log_line.to_s(:color => true)
                    end
                  else
                    lines_ignored += 1
                    if @options.verbose
                      $stderr.puts "[WARNING] ignoring line ##{lines_read}"
                    end
                  end
                end
              else
                unparsable_lines += 1
                if @options.verbose
                  $stderr.puts "[ERROR] cannot parse '#{raw_line}'"
                end
              end
            rescue
              $stderr.puts "[ERROR] processing line #{ARGF.file.lineno} of file #{ARGF.filename} resulted in #{$!.message}"
              $stderr.puts "[ERROR] " + raw_line
              @options.exit = -1
              @options.running = false
              raise $! # TODO if the "re-raise exceptions" option has been set...
            end
          end
        end
      end
      
      if @options.verbose
        $stderr.puts if @options.interrupted
        $stderr.print "[INFO] read #{lines_read} line(s) in #{files_read} file(s)"
        $stderr.print " (interrupted)" if @options.interrupted ; $stderr.puts
        $stderr.puts "[INFO] #{parsable_lines} parsable lines, #{unparsable_lines} unparsable lines"
        $stderr.puts "[INFO] processed #{lines_processed} lines, ignored #{lines_ignored} lines"
      end
      
      return @options.exit
      
    end
    
  end
end
