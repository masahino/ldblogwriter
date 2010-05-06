# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/parser.rb'
require 'ldblogwriter/entry.rb'
require 'ldblogwriter/service.rb'

module LDBlogWriter
  class EntryManager
    def save_edit_uri(filename, edit_uri)
    end
  end

  module Service
    class DummyService
      def post_image(image_path, image_title)
        return "http://example.com/hoge"
      end
    end
  end
end

class TestParser < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new('test/test.conf')
    service = LDBlogWriter::Service::DummyService.new()
    @parser = LDBlogWriter::Parser.new(@conf, nil, service)
  end

    def test_to_html
      str = "テスト。\n\n空行ごとに分離されるとうれしいな。\n"
      assert_equal("<p>\nテスト。\n</p>\n<p>\n空行ごとに分離されるとうれしいな。\n</p>", 
                   @parser.to_html(str))
    end

  def test_parse_img
    assert(@parser.parse_img('#img(test/test.jpg)'))
    assert_equal(['<a href="http://example.com/hoge" target="_blank"><img src="http://example.com/hoge" alt="test" hspace="5" class="pict" align="left" /></a>'],
                 @parser.parse_img('#img(test.jpg, test)'))
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

  def test_parse_inline
    assert_equal("<a class=\"outlink\" href=\"http://www.google.com\">http://www.google.com</a>", 
                 @parser.parse_inline("http://www.google.com"))
  end

#  def test_parse_pre_highlight
#    assert_equal("<div class=\"ruby\"><pre><span class=\"keyword\">def </span><span class=\"method\">hoge</span><span class=\"punct\">()</span>\n<span class=\"keyword\">end</span></pre></div>\n",
#                 @parser.to_html(" highlight(ruby)\n def hoge()\n end"))
#  end

  def test_parse_a_href
    entry = LDBlogWriter::BlogEntry.new(@conf, "test", "category")
    ret = @parser.to_html("[[hoge:http://blog.livedoor.jp/masahino123/archives/64994357.html]]", entry)
    assert_equal("<p>\n<a class=\"outlink\" href=\"http://blog.livedoor.jp/masahino123/archives/64994357.html\">hoge</a>\n</p>", ret)
    
    ret = @parser.to_html("[[hoge:http://www.google.co.jp/intl/en_com/images/srpr/logo1w.png]]", entry)
    assert_equal("<p>\n<a href=\"http://www.google.co.jp/intl/en_com/images/srpr/logo1w.png\" target=\"_blank\"><img src=\"http://www.google.co.jp/intl/en_com/images/srpr/logo1w-s.png\" alt=\"hoge\" hspace=\"5\" class=\"pict\" align=\"left\" /></a>\n</p>", ret)
  end

  def test_parse_trackback
    entry = LDBlogWriter::BlogEntry.new(@conf, "test", "category")
    @parser.to_html("#trackback(http://app.blog.livedoor.jp/masahino123/tb.cgi/64994357)", entry)
    assert_equal(["http://app.blog.livedoor.jp/masahino123/tb.cgi/64994357"],
                 entry.trackback_url_array)
  end

  def test_syntax_highlight
    
  end
  
  def test_parse_plugin
    
  end

  def test_get_img_html
  end

  def test_parse_p
  end

  def test_a_href
  end

  def test_get_entry
    entry = @parser.get_entry("<hoge> title")
    assert_equal("hoge", entry.category)
    assert_equal("title", entry.title)

    entry = @parser.get_entry("title2")
    assert_equal(nil, entry.category)
    assert_equal("title2", entry.title)
    entry
  end
end
