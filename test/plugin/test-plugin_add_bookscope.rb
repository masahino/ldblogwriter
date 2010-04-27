# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'mechanize'
require 'mocha'
require 'test/unit'
require 'ldblogwriter/config.rb'
require 'add_bookscope.rb'

class TestPluginAddBookScope < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
  end

  def test_no_userid
    @conf.options['bookscope_name'] = nil
    assert_equal("<!-- ユーザIDが設定されていません -->\n", add_bookscope('1'))
  end

  def test_add_bookscope
    WWW::Mechanize.any_instance.stubs(:post).returns("hoge")

    @conf.options['bookscope_name'] = 'testid'
    assert_equal("", add_bookscope('1'))
  end
  
end
