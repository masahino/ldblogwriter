$LOAD_PATH.unshift '../lib'

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

  def test_eval_post
    @plugin.eval_src('hoge("aa","bb")')
    @plugin.eval_post
  end
end
