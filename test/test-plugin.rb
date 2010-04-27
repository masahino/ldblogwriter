$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/plugin.rb'
require 'ldblogwriter/entry.rb'

require 'test/plugin/test-plugin_add_bookscope.rb'
require 'test/plugin/test-plugin_asin.rb'
require 'test/plugin/test-plugin_booklog.rb'
require 'test/plugin/test-plugin_google.rb'
require 'test/plugin/test-plugin_google_staticmap.rb'
require 'test/plugin/test-plugin_hatenagraph.rb'
require 'test/plugin/test-plugin_niconico.rb'
require 'test/plugin/test-plugin_pics.rb'
require 'test/plugin/test-plugin_stack.rb'
require 'test/plugin/test-plugin_tag.rb'
require 'test/plugin/test-plugin_youtube.rb'

class TestPlugin < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    @plugin = LDBlogWriter::Plugin.new(@conf)
  end
  
  def test_eval_src
#    p @plugin.eval_src("hoge")
  end

  def test_load_plugins
  end

  def test_load_plugin
  end

  def test_eval_post
    @plugin.eval_src('hoge("aa","bb")')
    @plugin.eval_post(LDBlogWriter::BlogEntry.new(@conf, "test"))
  end
end
