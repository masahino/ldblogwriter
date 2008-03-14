$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter-lib.rb'

class TestLDBlogWriter < Test::Unit::TestCase
  def setup

  end

  def test_get_blog_info
    LDBlogWriter::Blog.new
  end

  def test_check_img_file
    blog = LDBlogWriter::Blog.new
    assert_equal("img(../test/test.jpg)\n\nhogehoge", blog.check_image_file("../test/test.txt", "hogehoge"))
    assert_equal("img(test.jpg)\n\nhogehoge", blog.check_image_file("test.txt", "hogehoge"))
    assert_equal("hogehoge", blog.check_image_file("nofile.txt", "hogehoge"))
  end
end
