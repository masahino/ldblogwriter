require 'test/unit'
require 'config.rb'
require 'parser.rb'


module LDBlogWriter
  class Command
    def upload(atom_uri, user, pass, filename, title = nil)
      return 'http://image.blog.livedoor.jp/test_user/imgs/8/a/8a4d2846.jpg'
    end
  end
end

class TestParser < Test::Unit::TestCase
  def setup
    @parser = LDBlogWriter::Parser.new(LivedoorBlogWriter::Config.new('test.conf'))
  end

    def test_to_html
      assert_equal("<p>\nテスト。\n</p>\n<p>\n空行ごとに分離されるとうれしいな。\n</p>", 
                   @parser.to_html("テスト。\n\n空行ごとに分離されるとうれしいな。\n"))
    end

  def test_parse_img
    assert(@parser.parse_img('img(../../misc/test.jpg)'))
    assert_equal(['<a href="http://image.blog.livedoor.jp/test_user/imgs/8/a/8a4d2846.jpg" target="_blank"><img src="http://image.blog.livedoor.jp/test_user/imgs/8/a/8a4d2846-s.jpg" alt="test" hspace="5" class="pict" align="left" /></a>'],
                 @parser.parse_img('img(../../misc/test.jpg, test)'))
  end

  def test_parse_ul
    assert_equal("<ul>\n<li>hoge\n</li>\n<li>hogehoge\n</li>\n</ul>",
                 @parser.to_html("-hoge\n-hogehoge"))
  end

  def test_parse_ol
    assert_equal("<ol>\n<li>hoge\n</li>\n<li>hogehoge\n</li>\n</ol>",
                 @parser.to_html("+hoge\n+hogehoge"))
  end

  def test_parse_pre
    assert_equal("<pre>hoge\nhogehoge\n</pre>",
                 @parser.to_html(" hoge\n hogehoge"))
  end

  def test_parse_quote
    assert_equal("<blockquote><p>\nhoge\nhogehoge\n</p></blockquote>",
                 @parser.to_html(">hoge\n>hogehoge"))
  end

  def test_take_block
    assert_equal(["hoge", "hogehoge"],
                 @parser.take_block([" hoge", " hogehoge"], /\A\s/))
  end

  def test_escape_html
    assert_equal('&amp;', @parser.escape_html("&"))
    assert_equal('&quot;', @parser.escape_html("\""))
    assert_equal('&lt;', @parser.escape_html("<"))
    assert_equal('&gt;', @parser.escape_html(">"))
  end

  def test_get_small_img_uri
    assert_equal('http://image.blog.livedoor.jp/test_user/imgs/8/a/8a4d2846-s.jpg', @parser.get_small_img_uri('http://image.blog.livedoor.jp/test_user/imgs/8/a/8a4d2846.jpg'))
  end
end
