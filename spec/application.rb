require 'spec_helper'

describe NginxTail::Application do
  
  describe "#initialize" do
    
    it "sets 0 as the default 'exit' value" do
      application = NginxTail::Application.new
      application.exit.should == 0
    end
    
    it "sets true as the default 'running' value" do
      application = NginxTail::Application.new
      application.running.should == true
    end

    it "sets true as the default 'interrupted' value" do
      application = NginxTail::Application.new
      application.interrupted.should == false
    end
    
  end
  
end
