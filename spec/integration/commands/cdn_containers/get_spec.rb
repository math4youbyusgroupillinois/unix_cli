require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:get command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = storage_connection
    @hp_cdn = cdn_connection
    begin
      purge_containers(@hp_svc)
    rescue
      # ignore errors
    end
  end

  context "for an existing CDN container" do
    before(:all) do
      @hp_svc.put_container('my-added-container')
      @hp_cdn.put_container('my-added-container')
    end
    context "getting the value of a valid attribute" do
      it "should get the correct value" do
        rsp = cptr('cdn:containers:set my-added-container X-Ttl 900')
        rsp.stderr.should eq("")

        rsp = cptr('cdn:containers:get my-added-container X-Ttl')

        rsp.stderr.should eq("")
        rsp.stdout.should eq("900\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "getting the value of an invalid attribute" do
      it "should show error message" do
        rsp = cptr('cdn:containers:get my-added-container blah')

        rsp.stderr.should eq("The value of the attribute 'blah' cannot be retrieved. The allowed attributes are 'X-Ttl, X-Cdn-Uri, X-Cdn-Enabled, X-Log-Retention'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:incorrect_usage)
      end
    end

    after(:all) do
      @hp_svc.delete_container('my-added-container')
      @hp_cdn.delete_container('my-added-container')
    end
  end

  context "for a non-existent CDN container" do
    it "should show error message" do
      rsp = cptr('cdn:containers:get not-a-container blah')

      rsp.stderr.should eq("You don't have a container named 'not-a-container' on the CDN.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "cdn:containers:get with valid avl" do
    it "should report success" do
      @hp_svc.put_container('my-added-container2')
      @hp_cdn.put_container('my-added-container2')
      rsp = cptr('cdn:containers:set my-added-container2 X-Ttl 900')
      rsp.stderr.should eq("")

      rsp = cptr('cdn:containers:get my-added-container2 X-Ttl -z region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("900\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:all) do
      @hp_cdn.delete_container('my-added-container2')
      @hp_svc.delete_container('my-added-container2')
    end
  end

  context "cdn:containers:get with invalid avl" do
    it "should report error" do
      rsp = cptr('cdn:containers:get my-added-container2 X-Ttl -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("cdn:containers:get -a bogus container X-Ttl")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
