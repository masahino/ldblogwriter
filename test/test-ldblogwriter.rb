$LOAD_PATH << '../lib'

require 'test/unit'
require 'ldblogwriter-lib.rb'

class TestLDBlogWriter < Test::Unit::TestCase
  def setup

  end

  def test_get_blog_info
    LDBlogWriter::Blog.new
  end

end
