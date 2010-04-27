$LOAD_PATH.unshift 'lib'

require 'test/unit'
#require 'ldblogwriter/plugin.rb'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/plugin/asin.rb'

class TestPluginTag < Test::Unit::TestCase
  def setup
    @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    end

  
end
