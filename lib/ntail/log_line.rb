module Ntail
  class LogLine

    attr_reader :raw_log_line
    attr_reader :log_line_regexp

    attr_reader :filename
    attr_reader :line_number

    def initialize(raw_log_line, log_line_regexp, filename = nil, line_number = nil)
      raise ArgumentError.new("Required 'raw_log_line' and 'log_line_regexp' parameters are missing") if raw_log_line.nil? && log_line_regexp.nil?
      raise ArgumentError.new("Required 'raw_log_line' parameter is missing") if raw_log_line.nil?
      raise ArgumentError.new("Required 'log_line_regexp' parameter is missing") if log_line_regexp.nil?
      @raw_log_line = raw_log_line
      @log_line_regexp = log_line_regexp
      @filename = filename
      @line_number = line_number
    end

  end
end
