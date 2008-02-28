require 'test/unit'
require 'config.rb'
require 'plugin.rb'

class TestPlugin < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    @plugin = LDBlogWriter::Plugin.new(@conf)
  end
  
  def test_eval_src
    p @plugin.eval_src("hoge")
  end

end
