$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'hatenagraph.rb'

class TestPluginHatenaGraph < Test::Unit::TestCase
  def setup
    @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    end

  
end
