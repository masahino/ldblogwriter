# -*- coding: utf-8 -*-
$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/command.rb'
require 'ldblogwriter/entry.rb'

class TestCommand < Test::Unit::TestCase
  def setup
  end

  def test_google_auth_token
  end

  def test_get_auth_info
    com = LDBlogWriter::Command.new('hoge')
    assert_raise(ArgumentError) {com.get_auth_info("hoge", "huga")}

    com = LDBlogWriter::Command.new
    assert_equal('wsse', com.auth_type)
    ret = com.get_auth_info("hoge", "huga")
    assert_equal('X-WSSE', ret.keys[0])

    com = LDBlogWriter::Command.new('google')
    assert_equal('google', com.auth_type)
#    ret = com.get_auth_info("hoge", "huga")
#    assert_equal('Authorization', ret.keys[0])
  end

  def test_get
  end

  def test_upload
  end

  def test_post
    test_entry = LDBlogWriter::BlogEntry.new(LDBlogWriter::Config.new('test.conf'),
                                             "タイトル",
                                             "カテゴリ",
                                             "コンテンツ")
    LDBlogWriter::Command.new.post('http://localhost:8080/', 'user', 'pass', 
                                   test_entry)
  end

  def test_edit
  end

  def test_delete
  end

end
