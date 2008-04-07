$LOAD_PATH << '../lib'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/plugin.rb'

class TestPlugin < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    @plugin = LDBlogWriter::Plugin.new(@conf)
  end
  
  def test_eval_src
    p @plugin.eval_src("hoge")
  end

  def test_load_plugins
  end

  def test_load_plugin
  end

  
end
