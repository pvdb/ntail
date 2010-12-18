require 'ostruct'
require 'optparse'

module NginxTail
  class Application
    
    def self.options
      # application options from the command line
      @@options ||= OpenStruct.new
    end
    
    def self.standard_ntail_options
      [
        ['-v', '--version', '-V', "Display the program version.",
          lambda { |value|
            puts "#{NTAIL_NAME}, version #{NTAIL_VERSION}"
            self.options.exit = true
          }
        ],
      ]
    end

    def self.parse_options
      OptionParser.new do |opts|
        opts.banner = "ntail {options} ..."
        opts.separator ""
        opts.separator "Options are ..."

        opts.on_tail("-h", "--help", "-H", "Display this help message.") do
          puts opts
          self.options.exit = true
        end

        standard_ntail_options.each { |args| opts.on(*args) }
      end.parse!
    end
    
    def self.run!(*argv)
      self.parse_options
      unless self.options.exit
        ARGF.each_line do |line|
          puts line
        end
      end
      return 0
    end # def run
    
  end
end
