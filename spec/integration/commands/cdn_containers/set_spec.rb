# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:set command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = storage_connection
    @hp_cdn = cdn_connection
  end

  context "for an existing CDN container" do
    before(:all) do
      @hp_svc.put_container('my-added-container')
      @hp_cdn.put_container('my-added-container')
    end

    context "setting an attribute with a valid value" do
      it "should show success message" do
        rsp = cptr('cdn:containers:set my-added-container X-Ttl 900')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("The attribute 'X-Ttl' with value '900' was set on CDN container 'my-added-container'.\n")
        rsp.exit_status.should be_exit(:success)
        response = @hp_cdn.head_container('my-added-container')
        response.headers['X-Ttl'].should eql("900")
      end
    end

    context "setting :container attribute with a valid value" do
      it "should show success message" do
        rsp = cptr('cdn:containers:set :my-added-container X-Ttl 900')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("The attribute 'X-Ttl' with value '900' was set on CDN container 'my-added-container'.\n")
        rsp.exit_status.should be_exit(:success)
        response = @hp_cdn.head_container('my-added-container')
        response.headers['X-Ttl'].should eql("900")
      end
    end

    context "setting an attribute with an invalid value" do
      it "should show error message" do
        rsp = cptr('cdn:containers:set my-added-container X-Ttl 1')

        rsp.stderr.should include("400 Bad Request")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:incorrect_usage)
      end
    end

    context "setting an invalid attribute" do
      it "should show error message" do
        rsp = cptr('cdn:containers:set my-added-container blah 1')

        rsp.stderr.should eq("The attribute 'blah' cannot be set. The allowed attributes are 'X-Ttl, X-Cdn-Uri, X-Cdn-Enabled, X-Log-Retention'.\n")
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
      rsp = cptr('cdn:containers:set not-a-container blah 1')

      rsp.stderr.should eql("You don't have a container named 'not-a-container' on the CDN.\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "cdn:containers:set with valid avl" do
    it "should report success" do
      @hp_svc.put_container('my-added-container2')
      @hp_cdn.put_container('my-added-container2')

      rsp = cptr("cdn:containers:set my-added-container2 X-Ttl 900 -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("The attribute 'X-Ttl' with value '900' was set on CDN container 'my-added-container2'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:all) do
      @hp_cdn.delete_container('my-added-container2')
      @hp_svc.delete_container('my-added-container2')
    end
  end

  context "cdn:containers:set with invalid avl" do
    it "should report error" do
      rsp = cptr('cdn:containers:set my-added-container2 X-Ttl 900 -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("cdn:containers:set my-added-container2 X-Ttl 900 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
