# -*- coding: utf-8 -*-
# BookScope (http://bookscope.net/ に蔵書を追加する
# - 設定
# bookscope_name: ユーザ名
# bookscope_email: ログインに使うメールアドレス
# bookscope_password: パスワード
#
# - 使い方
# add_bookscope(<ASIN>)

require 'rubygems'

def add_bookscope(asin)
  begin
    require 'mechanize'
  rescue LoadError
    "<!-- mechanizeが無い -->\n"
    return
  end
  email = @conf.options['bookscope_email']
  user_name = @conf.options['bookscope_name']
  password = @conf.options['bookscope_password']
  if user_name == nil
    "<!-- ユーザIDが設定されていません -->\n"
  end
  agent = Mechanize.new
  login_form = agent.get("http://bookscope.net/").form_with(:action => /login/)
  login_form['email'] = email
  login_form['password'] = password
  login_form.submit
#  ret = agent.post("http://bookscope.net/account/login", 'email' => email,
#                   'password' => password)
  #  $stderr.puts ret.body
  bookscope_uri = "http://bookscope.net/#{user_name}/belongings/create?barcode=#{asin}"
  $stderr.puts bookscope_uri
  #  puts bookscope_uri
  begin
    ret = agent.get(bookscope_uri)
  rescue
  end
  return ""
end


if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'
  require 'ldblogwriter/config'

  class TestAddBookScope < Test::Unit::TestCase
    def setup
      @conf = LDBlogWriter::Config.new()
      @conf.options['bookscope_name'] = 'testid'
    end

    def test_no_userid
      assert_equal("<!-- ユーザIDが設定されていません -->\n", add_bookscope('1'))
    end

    def test_add_bookscope
      @conf = LDBlogWriter::Config.new(ENV['HOME']+"/.ldblogwriter.conf")
      assert_equal("<!-- BookScopeに登録しました -->\n", add_bookscope('4480427937'))
    end
  end
end
