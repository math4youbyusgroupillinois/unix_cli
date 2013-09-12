require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "images:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()
  end

  context "when deleting an image by name" do
    it "should show success message" do
      @image_name = resource_name("del")
      @server = ServerTestHelper.create("cli_test_srv3")
      new_image_id = @server.create_image(@image_name, {})
      sleep(10)

      rsp = cptr("images:remove #{@image_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed image '#{@image_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      sleep(10)
      images = @hp_svc.images.map {|i| i.id}
      images.should_not include(new_image_id)
      image = @hp_svc.images.get(new_image_id)
      image.should be_nil
    end
  end

  context "images:add with valid avl" do
    it "should report success" do
      @image_name2 = resource_name("del2")
      @server2 = ServerTestHelper.create("cli_test_srv2")
      @image_id2 = @server2.create_image(@image_name2, {})
      sleep(10)

      rsp = cptr("images:remove #{@image_id2} -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed image '#{@image_name2}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "images:add with invalid avl" do
    it "should report error" do
      rsp = cptr("images:remove imgur -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "images:remove with invalid image" do
    it "should report error" do
      rsp = cptr("images:remove bogus")
      rsp.stderr.should eq("Cannot find a image matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images:remove -a bogus bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
