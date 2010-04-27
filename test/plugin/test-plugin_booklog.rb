$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'mechanize'
require 'mocha'

require 'test/unit'

require 'ldblogwriter/config.rb'
require 'booklog.rb'

class TestPluginBookLog < Test::Unit::TestCase
  def setup
    @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
  end
  
end
