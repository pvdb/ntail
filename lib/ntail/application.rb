require 'ostruct'
require 'optparse'

module NginxTail
  class Application
    
    def self.options
      # application options from the command line
      @@options ||= OpenStruct.new
    end
    
    def self.ntail_options
      # shamelessly copied from lib/rake.rb (rake gem)
      [
        ['--verbose', '--v', "Run verbosely (log messages to STDERR).",
          lambda { |value|
            self.options.verbose = true
          }
        ],
        ['--version', '-V', "Display the program version.",
          lambda { |value|
            puts "#{NTAIL_NAME}, version #{NTAIL_VERSION}"
            self.options.exit = true
          }
        ],
        ['--filter',  '-f CODE', "Ruby code block for filtering (parsed) lines - needs to return true or false.",
          lambda { |value|
            self.options.filter = eval "Proc.new #{value}"
          }
        ],
        ['--execute',  '-e CODE', "Ruby code block for processing each (parsed) line.",
          lambda { |value|
            self.options.code = eval "Proc.new #{value}"
          }
        ],
      ]
    end

    def self.parse_options
      OptionParser.new do |opts|
        opts.banner = "ntail {options} {file(s)} ..."
        opts.separator ""
        opts.separator "Options are ..."

        opts.on_tail("-h", "--help", "-H", "Display this help message.") do
          puts opts
          self.options.exit = true
        end

        self.ntail_options.each { |args| opts.on(*args) }
      end.parse!
    end
    
    def self.run!
      self.parse_options
      unless self.options.exit
        lines_read = lines_processed = lines_ignored = 0
        ARGF.each_line do |line|
          line = line.chomp ; lines_read += 1
          if !self.options.filter || self.options.filter.call(line)
            lines_processed += 1
            if self.options.code
              self.options.code.call line
            else
              puts line
            end
          else
            lines_ignored += 1
            if self.options.verbose
              $stderr.puts "[WARN] ignoring line ##{lines_read}"
            end
          end
        end
      end
      if self.options.verbose
        $stderr.puts "[INFO] read #{lines_read} lines, processed #{lines_processed} lines, ignored #{lines_ignored} lines"
      end
      return 0
    end # def run
    
  end
end
