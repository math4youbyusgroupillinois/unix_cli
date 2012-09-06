require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "containers command" do
  describe "with avl settings from config" do
    context "containers" do
      it "should report success" do
        rsp = cptr('containers')
        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "containers:list" do
      it "should report success" do
        rsp = cptr('containers:list')
        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:success)
      end
    end
  end
  describe "with avl settings passed in" do
    context "containers with valid avl" do
      it "should report success" do
        rsp = cptr('containers:list -z region-a.geo-1')
        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:success)
      end
    end
    context "containers with invalid avl" do
      it "should report error" do
        rsp = cptr('containers:list -z blah')
        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("containers -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
