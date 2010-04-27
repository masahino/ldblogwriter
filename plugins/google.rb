# -*- coding: utf-8 -*-
require 'pp'
require 'uri'
 
# googleの検索結果へのリンクを作成
def google(str)
  uri = URI.encode("http://www.google.co.jp/search?hl=ja&q=#{str}&lr=lang_ja")
  %Q!<a href="#{uri}">#{str}</a>!
end
