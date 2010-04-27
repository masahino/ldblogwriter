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
    return "<!-- mechanizeが無い -->\n"
  end
  email = @conf.options['bookscope_email']
  user_name = @conf.options['bookscope_name']
  password = @conf.options['bookscope_password']
  if user_name == nil
    return "<!-- ユーザIDが設定されていません -->\n"
  end
  agent = WWW::Mechanize.new
  ret = agent.post("http://bookscope.net/account/login", 'email' => email,
                   'password' => password)
  #  $stderr.puts ret.body
  bookscope_uri = "http://bookscope.net/#{user_name}/belongings/create?barcode=#{asin}"
  if $DEBuG
    $stderr.puts bookscope_uri
  end
  #  puts bookscope_uri
  ret = agent.get(bookscope_uri).body
  return ""
end

