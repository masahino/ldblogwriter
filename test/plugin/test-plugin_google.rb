# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'google.rb'

class TestPluginGoogle < Test::Unit::TestCase
  def setup
  end

  def test_google
    assert_equal(%Q!<a href="http://www.google.co.jp/search?hl=ja&q=%E3%81%BB%E3%81%92&lr=lang_ja">ほげ</a>!, google("ほげ"))
  end
end
