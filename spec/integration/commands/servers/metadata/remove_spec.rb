require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/server_helper'

describe "Servers metadata remove command" do
  before(:all) do
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()

    @srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
    @srv.name = resource_name("meta_srv")
    @srv.flavor = @flavor_id
    @srv.image = @image_id
    @srv.meta.set_metadata('aardvark=three,luke=skywalker,han=solo,kangaroo=two')
    @srv.save.should be_true
    @srv.fog.wait_for { ready? }

    @server_id = "#{@srv.id}"
    @server_name = @srv.name
  end

  before(:each) do
    @srv = Servers.new.get(@server_id)
    @srv.meta.set_metadata('aardvark=three,luke=skywalker,han=solo,kangaroo=two')
  end

  def still_contains_original(metastr)
    metastr.should include("luke=skywalker")
    metastr.should include("han=solo")
  end

  describe "with avl settings from config" do
    context "servers delete one" do
      it "should report success" do
        rsp = cptr("servers:metadata:remove #{@server_id} aardvark")

        rsp.stderr.should eq("")
        rsp.stdout.should include("aardvark")
        rsp.exit_status.should be_exit(:success)
        result = Servers.new.get(@server_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should include("kangaroo=two")
        result.meta.to_s.should_not include("aardvark")
      end
    end

    context "servers" do
      it "should report success" do
        rsp = cptr("servers:metadata:remove #{@server_name} aardvark kangaroo")

        rsp.stderr.should eq("")
        rsp.stdout.should include("aardvark")
        rsp.stdout.should include("kangaroo")
        rsp.exit_status.should be_exit(:success)
        result = Servers.new.get(@server_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should_not include("kangaroo")
        result.meta.to_s.should_not include("aardvark")
      end
    end

  end

  describe "with avl settings passed in" do
    context "servers with valid avl" do
      it "should report success" do
        rsp = cptr("servers:metadata:remove -z az-1.region-a.geo-1 #{@server_id} aardvark kangaroo")

        rsp.stderr.should eq("")
        rsp.stdout.should include("Removed metadata 'aardvark' from server")
        rsp.stdout.should include("Removed metadata 'kangaroo' from server")
        rsp.exit_status.should be_exit(:success)
        result = Servers.new.get(@server_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should_not include("kangaroo")
        result.meta.to_s.should_not include("aardvark")
      end
    end

    context "servers with invalid avl" do
      it "should report error" do
        rsp = cptr("servers:metadata:remove -z blah #{@server_id} aardvark kangaroo")

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { HP::Cloud::Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:metadata:remove #{@server_id} aardvark kangaroo -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @srv.destroy() unless @srv.nil?
  end
end