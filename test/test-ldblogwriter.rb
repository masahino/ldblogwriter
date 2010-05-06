$LOAD_PATH.unshift 'lib'

require 'mocha'

require 'test/unit'
require 'ldblogwriter.rb'

require 'test/test-atom_response.rb'
require 'test/test-config.rb'
require 'test/test-entry.rb'
require 'test/test-entry_manager.rb'
require 'test/test-parser.rb'
require 'test/test-plugin.rb'
require 'test/test-service.rb'
require 'test/test-service_builder.rb'
require 'test/test-trackback.rb'
require 'test/test-wsse.rb'


class TestLDBlogWriter < Test::Unit::TestCase
  def setup

  end

  def test_get_blog_info
    LDBlogWriter::Blog.new
  end

  def test_check_img_file
    blog = LDBlogWriter::Blog.new
    assert_equal("#img(test/test.jpg)\n\nhogehoge", 
                 blog.check_image_file("test/test.txt", "hogehoge"))
    assert_equal("hogehoge", blog.check_image_file("nofile.txt", "hogehoge"))
    assert_equal("#img(test/test2.png)\n\nhogehoge",
                 blog.check_image_file("test/test2.txt", "hogehoge"))
  end
end
