$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter/wsse.rb'

class TestWsse < Test::Unit::TestCase
  def setup
  end

  def test_get
    assert(LDBlogWriter::Wsse::get('user', 'pass'))
    puts LDBlogWriter::Wsse::get('user', 'pass')
  end

end
