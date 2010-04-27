$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'google_staticmap.rb'

class TestPluginGoogleStaticMap < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    end

end
