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

module HP
  module Cloud
    class CLI < Thor

      map %w(fetch) => 'get'

      desc 'get object [object ...]', 'Fetch objects to your local directory.'
      long_desc <<-DESC
  Copy remote objects from a container to your current directory. Optionally, you can specify an availability zone.

Examples: 
  hpcloud get :my_container/file.txt :my_container/resume.txt  # Copy `file.txt` and `resume.txt` to your current directory
  hpcloud get :my_container/file.txt -z region-a.geo-1    # Copy `file.txt` to your current directory for availability zone `region-a.geo-1`

Aliases: fetch
      DESC
      CLI.add_common_options
      def get(source, *sources)
        cli_command(options) {
          sources = [source] + sources
          to = ResourceFactory.create(Connection.instance.storage, ".")
          sources.each { |name|
            from = ResourceFactory.create(Connection.instance.storage, name)
            if from.isRemote() == false
              @log.error "Source object does not appear to be remote '#{from.fname}'.", :incorrect_usage
            elsif to.copy(from)
              @log.display "Copied #{from.fname} => #{to.fname}"
            else
              @log.fatal to.cstatus
            end
          }
        }
      end
    end
  end
end

