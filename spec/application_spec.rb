require 'spec_helper'

describe NginxTail::Application do

  %w{ exit running interrupted }.each do |option|
    it "should respond to #{option} option method" do
      NginxTail::Application.new.should respond_to(option.to_sym)
    end
  end

  # specs governing processing behaviour

  it "has a default 'exit' value of 0" do
    NginxTail::Application.new.exit.should eq(0)
  end
  
  it "has a default 'running' value of true" do
    NginxTail::Application.new.running.should eq(true)
  end

  it "has a default 'interrupted' value of false" do
    NginxTail::Application.new.interrupted.should eq(false)
  end

  # specs governing the help function

  it "doesn't run when printing help" do
    stfu do
      NginxTail::Application.new(['--help']).running.should eq(false)
    end
  end

  # specs governing pattern matching behaviour

  it "has a default 'pattern' value for nginx" do
    NginxTail::Application.new.pattern.should eq(:nginx)
  end

  it "has a 'pattern' that can be set via options" do
    NginxTail::Application.new(['--apache']).pattern.should eq(:apache)
  end
  
end
