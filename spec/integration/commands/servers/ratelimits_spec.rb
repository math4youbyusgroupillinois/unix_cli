require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:ratelimits" do
  context "servers:ratelimits" do
    it "should report success" do
      rsp = cptr("servers:ratelimits")

      rsp.stderr.should eq("")
      rsp.stdout.should include("POST")
      rsp.stdout.should include("PUT")
      rsp.stdout.should include("DELETE")
      rsp.exit_status.should be_exit(:success)
    end
  end
end