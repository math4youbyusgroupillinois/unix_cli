require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Servers command" do
  describe "with avl settings from config" do
    context "servers" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['servers']) }
        exit_status.should be_exit(:success)
      end
    end

    context "servers:list" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['servers:list']) }
        exit_status.should be_exit(:success)
      end
    end
  end
  describe "with avl settings passed in" do
    context "servers with valid avl" do
      it "should report success" do
        response, exit_status = run_command('servers -z az-1.region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "servers with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('servers -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

end
