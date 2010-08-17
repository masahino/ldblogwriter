$LOAD_PATH.unshift 'lib'

require 'test/unit'

require 'ldblogwriter/config.rb'
require 'ldblogwriter/parser.rb'
require 'ldblogwriter/trackback.rb'

class TestTrackBack < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new('test/test.conf')
    @parser = LDBlogWriter::Parser.new(@conf, nil)
  end

  def test_send
  end

end
