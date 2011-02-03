require 'ostruct'
require 'optparse'

module NginxTail
  class Application
    
    def self.options
      # application options from the command line
      @@options ||= OpenStruct.new
    end
    
    def self.parse_options

      # application defaults...
      self.options.interrupted = false
      self.options.running = true
      self.options.exit = 0

      OptionParser.new do |opts|

        opts.banner = "Usage: ntail {options} {file(s)}"
        opts.separator ""
        opts.separator "Options are ..."

        opts.on '--verbose', '-v', "Run verbosely (log messages to STDERR)." do |value|
          self.options.verbose = true
        end

        opts.on '--filter',  '-f CODE', "Ruby code block for filtering (parsed) lines - needs to return true or false." do |value|
          self.options.filter = eval "Proc.new #{value}"
        end

        opts.on '--execute',  '-e CODE', "Ruby code block for processing each (parsed) line." do |value|
          self.options.code = eval "Proc.new #{value}"
        end

        opts.on '--line-number', '-l LINE_NUMBER', "Only process the line with the given line number" do |value|
          self.options.line_number = value.to_i
        end

        opts.on '--dry-run', '-n', "Dry-run: process files, but don't actually parse the lines" do |value|
          self.options.dry_run = true
        end

        opts.on '--parse-only', '-p', "Parse only: parse all lines, but don't actually process them" do |value|
          self.options.parse_only = true
        end

        opts.on '--version', '-V', "Display the program version." do |value|
          puts "#{NTAIL_NAME}, version #{NTAIL_VERSION}"
          self.options.running = false
        end

        opts.on_tail("-h", "--help", "-H", "Display this help message.") do
          puts opts
          self.options.running = false
        end

      end.parse!

    end
    
    def self.run!
      
      self.parse_options
      
      ['TERM', 'INT'].each do |signal|
        Signal.trap(signal) do
          self.options.running = false ; self.options.interrupted = true
          $stdin.close if ARGF.file == $stdin # ie. reading from STDIN
        end
      end
      
      files_read = lines_read = lines_processed = lines_ignored = parsable_lines = unparsable_lines = 0
      
      while self.options.running and ARGF.gets
        if ARGF.file.lineno == 1
          files_read += 1
          if self.options.verbose
            $stderr.puts "[INFO] now processing file #{ARGF.filename}"
          end
        end
        raw_line = $_.chomp ; lines_read += 1
        unless self.options.dry_run
          if !self.options.line_number or self.options.line_number == ARGF.lineno
            begin
              log_line = NginxTail::LogLine.new(raw_line)
              if log_line.parsable
                parsable_lines += 1
                unless self.options.parse_only
                  if !self.options.filter || self.options.filter.call(log_line)
                    lines_processed += 1
                    if self.options.code
                      self.options.code.call(log_line)
                    else
                      puts log_line
                    end
                  else
                    lines_ignored += 1
                    if self.options.verbose
                      $stderr.puts "[WARNING] ignoring line ##{lines_read}"
                    end
                  end
                end
              else
                unparsable_lines += 1
                if self.options.verbose
                  $stderr.puts "[ERROR] cannot parse '#{raw_line}'"
                end
              end
            rescue
              $stderr.puts "[ERROR] processing line #{ARGF.file.lineno} of file #{ARGF.filename} resulted in #{$!.message}"
              $stderr.puts "[ERROR] " + raw_line
              self.options.exit = -1
              self.options.running = false
              raise $! # TODO if the "re-raise exceptions" option has been set...
            end
          end
        end
      end
      
      if self.options.verbose
        $stderr.puts if self.options.interrupted
        $stderr.print "[INFO] read #{lines_read} lines in #{files_read} files"
        $stderr.print " (interrupted)" if self.options.interrupted ; $stderr.puts
        $stderr.puts "[INFO] #{parsable_lines} parsable lines, #{unparsable_lines} unparsable lines"
        $stderr.puts "[INFO] processed #{lines_processed} lines, ignored #{lines_ignored} lines"
      end
      
      return self.options.exit
      
    end # def run
    
  end
end
