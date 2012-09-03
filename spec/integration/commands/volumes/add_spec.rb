require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "volumes:add command" do
  before(:all) do
    @hp_svc = HP::Cloud::Connection.instance.block
  end

  context "when creating volume with name description" do
    before(:all) do
      @volume_description = 'Add_volume'
      @volume_name = resource_name("add1")
      @response, @exit = run_command("volumes:add #{@volume_name} 1 -d #{@volume_description}").stdout_and_exit_status
      @new_volume_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created volume '#{@volume_name}' with id '#{@new_volume_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    it "should list id in volumes" do
      volumes = @hp_svc.volumes.map {|s| s.id}
      volumes.should include(@new_volume_id.to_i)
    end

    it "should list name in volumes" do
      volumes = @hp_svc.volumes.map {|s| s.name}
      volumes.should include(@volume_name)
    end

    it "should list description in volumes" do
      volumes = @hp_svc.volumes.map {|s| s.description}
      volumes.should include(@volume_description)
    end

    after(:all) do
      @hp_svc.delete_volume(@new_volume_id) unless @new_volume_id.nil?
    end
  end

  context "when creating volume with name with no desciption" do
    before(:all) do
      @volume_name = resource_name("add2")
      @response, @exit = run_command("volumes:add #{@volume_name} 1").stdout_and_exit_status
      @new_volume_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created volume '#{@volume_name}' with id '#{@new_volume_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    it "should list id in volumes" do
      volumes = @hp_svc.volumes.map {|s| s.id}
      volumes.should include(@new_volume_id.to_i)
    end
    it "should list name in volumes" do
      volumes = @hp_svc.volumes.map {|s| s.name}
      volumes.should include(@volume_name)
    end

    after(:all) do
      @hp_svc.delete_volume(@new_volume_id) unless @new_volume_id.nil?
    end
  end

  context "when creating volume with a name that already exists" do
    it "should fail" do
      @volume_name = "volume-already-exists"
      cptr("volumes:add #{@volume_name} 1")
      rsp = cptr("volumes:add #{@volume_name} 1")
      rsp.stderr.should eq("Volume with the name '#{@volume_name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes:add voller 1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
