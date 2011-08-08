require 'ostruct'
require 'optparse'

module NginxTail
  class Application

    include NginxTail::Options

    # default application options...
    DEFAULT_OPTIONS = {
      :interrupted => false,
      :running => true,
      :nginx => true,
      :exit => 0,
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

      LogLine.set_log_pattern(@options.nginx)

      ['TERM', 'INT'].each do |signal|
        Signal.trap(signal) do
          @options.running = false ; @options.interrupted = true
          $stdin.close if ARGF.file == $stdin # ie. reading from STDIN
        end
      end

      files_read = lines_read = lines_processed = lines_ignored = parsable_lines = unparsable_lines = 0

      current_filename = nil ; current_line_number = 0 ; file_count = ARGV.count

      while @options.running and ARGF.gets
        if ARGF.file.lineno == 1
          current_filename = ARGF.filename ; current_line_number = 0
          files_read += 1
          if @options.verbose
            $stderr.puts "[INFO] now processing file #{ARGF.filename}"
          end
        end
        raw_line = $_.chomp ; lines_read += 1 ; current_line_number += 1
        unless @options.dry_run
          if !@options.line_number or @options.line_number == ARGF.lineno
            begin
              log_line = NginxTail::LogLine.new(raw_line, current_filename, current_line_number)
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
        if @options.progress
          progress_line = [
            " Processing file ".inverse + (" %d/%d" % [files_read, file_count]),
            " Current filename ".inverse + " " + current_filename.to_s,
            " Line number ".inverse + " " + current_line_number.to_s,
            " Lines processed ".inverse + " " + lines_read.to_s
          ].join(" \342\200\242 ")
          max_length = [max_length || 0, progress_line.size].max
          $stderr.print progress_line
          $stderr.print " " * (max_length - progress_line.size)
          $stderr.print "\r"
        end
      end

      $stderr.puts if @options.progress

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
