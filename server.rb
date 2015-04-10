# This file provided by Facebook is for non-commercial testing and evaluation purposes only.
# Facebook reserves all rights not expressly granted.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# NOTE that you will need to have Ruby installed for this to work.

require 'webrick'
require 'json'

port = ENV['PORT'].nil? ? 3000 : ENV['PORT'].to_i

puts "Server started: http://localhost:#{port}/"

root = File.expand_path './public'
server = WEBrick::HTTPServer.new :Port => port, :DocumentRoot => root


server.mount_proc '/comments.json' do |req, res|
  comments = JSON.parse(File.read('./comments.json'))

  if req.request_method == 'POST'
    # Assume it's well formed
    comments << req.query
    File.write('./comments.json', JSON.pretty_generate(comments, :indent => '    '))
  end

  # always return json
  res['Content-Type'] = 'application/json'
  res['Cache-Control'] = 'no-cache'
  res.body = JSON.generate(comments)
end


tutorialPage = 'Tutorial_20.html'

# Effectively renders the HTML content through Ruby / WEBrick.  This is to by-pass any issues regarding "Same-origin Policy".
server.mount_proc ('/' + tutorialPage) do |req, res|
  
  html = File.read('./' + tutorialPage)

  res['Content-Type'] = 'text/html'
  res['Cache-Control'] = 'no-cache'
  res.body = html

end


trap 'INT' do server.shutdown end

server.start