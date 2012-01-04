# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'test/unit'
require 'html.rb'

class TestPluginGoogle < Test::Unit::TestCase
  def setup
  end

  def test_html
    assert_equal("<p>hoge</p>", html('<p>hoge</p>'))
    assert_equal(%Q!<a href="http://www.google.com">google</a>!,
                 html('<a href="http://www.google.com">google</a>'))
  end
end
