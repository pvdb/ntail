require 'spec_helper'

describe Ntail::LogLine do

  let(:raw_log_line) {
    "Foo Bar Blegga Qux Thud"
  }

  let(:log_line_regexp) {
    /Blegga/
  }

  let(:filename) {
    "foo/bar/blegga.log"
  }

  let(:line_number) {
    666
  }

  describe '#initialize' do

    it 'requires raw_log_line and log_line_regexp as mandatory parameters' do
      # when
      log_line = described_class.new(raw_log_line, log_line_regexp)
      # then
      log_line.raw_log_line.should be raw_log_line
      # and
      log_line.log_line_regexp.should be log_line_regexp
    end

    it 'throws an exception if both raw_log_line and log_line_regexp are missing' do
      # when/then
      expect {
        described_class.new(nil, nil)
      }.to raise_error(ArgumentError, "Required 'raw_log_line' and 'log_line_regexp' parameters are missing")
    end

    it 'throws an exception if raw_log_line is missing' do
      # when/then
      expect {
        described_class.new(nil, log_line_regexp)
      }.to raise_error(ArgumentError, "Required 'raw_log_line' parameter is missing")
    end

    it 'throws an exception if log_line_regexp is missing' do
      # when/then
      expect {
        described_class.new(raw_log_line, nil)
      }.to raise_error(ArgumentError, "Required 'log_line_regexp' parameter is missing")
    end

    it 'accepts filename and line number as optional parameters' do
      # when
      log_line = described_class.new(raw_log_line, log_line_regexp, filename, line_number)
      # then
      log_line.filename.should be filename
      # and
      log_line.line_number.should be line_number
    end

    it 'still works if filename and line number are missing' do
      # when
      log_line = described_class.new(raw_log_line, log_line_regexp)
      # then
      log_line.filename.should be_nil
      # and
      log_line.line_number.should be_nil
    end

    it 'still works if filename and line number are nil' do
      # when
      log_line = described_class.new(raw_log_line, log_line_regexp, nil, nil)
      # then
      log_line.filename.should be_nil
      # and
      log_line.line_number.should be_nil
    end

  end

end
