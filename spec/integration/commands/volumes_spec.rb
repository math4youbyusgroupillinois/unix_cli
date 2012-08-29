require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Volumes command" do
  def then_expected_table(response)
    response.should match("| .*id.*|.*name.*|.*size.*|.*type.*|.*created.*|.*status.*|.*description.*|.*servers.*|\n")
    response.should match("| one *| 1 *| *|")
    response.should match("| two *| 1 *| *|")
  end

  before(:all) do
    VolumeTestHelper.create("one")
    VolumeTestHelper.create("two")
  end

  describe "with avl settings from config" do
    context "volumes" do
      it "should report success" do
        response, exit_status = run_command("volumes one two").stdout_and_exit_status
        exit_status.should be_exit(:success)
        then_expected_table(response)
      end
    end

    context "volumes:list" do
      it "should report success" do
        response, exit_status = run_command("volumes:list one two").stdout_and_exit_status
        exit_status.should be_exit(:success)
        then_expected_table(response)
      end
    end
  end

  describe "with avl settings passed in" do
    context "volumes with valid avl" do
      it "should report success" do
        response, exit_status = run_command('volumes one two -z az-1.region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
        then_expected_table(response)
      end
    end
    context "volumes with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('volumes -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
