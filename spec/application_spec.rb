require 'spec_helper'

describe NginxTail::Application do

  %w{ exit running interrupted }.each do |option|
    it "should respond to #{option} option method" do
      NginxTail::Application.new.should respond_to(option.to_sym)
    end
  end

  it "has a default 'exit' value of 0" do
    NginxTail::Application.new.exit.should eq(0)
  end
  
  it "has a default 'running' value of true" do
    NginxTail::Application.new.running.should eq(true)
  end

  it "has a default 'interrupted' value of false" do
    NginxTail::Application.new.interrupted.should eq(false)
  end
  
end
