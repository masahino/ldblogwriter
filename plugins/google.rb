# -*- coding: utf-8 -*-
require 'pp'
require 'uri'
 
# googleの検索結果へのリンクを作成
def google(str)
  uri = URI.encode("http://www.google.co.jp/search?hl=ja&q=#{str}&lr=lang_ja")
  %Q!<a href="#{uri}">#{str}</a>!
end

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'

  class TestGoogle < Test::Unit::TestCase
    def setup
    end

    def test_google
      assert_equal(%Q!<a href="http://www.google.co.jp/search?hl=ja&q=%E3%81%BB%E3%81%92&lr=lang_ja">ほげ</a>!, google("ほげ"))
    end
  end
end
