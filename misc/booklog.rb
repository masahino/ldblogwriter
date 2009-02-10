# -*- coding: utf-8 -*-
require 'rubygems'
module Booklog
  class Agent
    require 'mechanize'
    require 'kconv'

    BooklogHomeURI = 'http://booklog.jp'
    BooklogLoginURI = 'http://booklog.jp/login.php'
    BooklogInputURI = 'http://booklog.jp/input.php'
    def initialize(user_id, password)
      @agent = WWW::Mechanize.new
      authentication(@agent, user_id, password)
    end

    def authentication(agent, user_id, password)
      login_page = agent.get(BooklogLoginURI)
      login_form = login_page.forms.with.action("./uhome.php").first
      login_form['account'] = user_id
      login_form['pw'] = password
      result_page = login_form.submit
    end

    # ISBNによる登録
    def input(isbn_list)
      input_page = @agent.get(BooklogInputURI)
      input_form = input_page.form('frm')
      input_form['asin'] = isbn_list.join("\n")
      result_page = input_form.submit
    end

    def comment(asin, comment)
      update_uri = BooklogHomeURI + '/addbook.php?mode=ItemLookup&asin='+asin
      #p update_uri
      comment_page = @agent.get(update_uri)
      comment_form = comment_page.form('frm')
      comment_form['comment'] = comment.toeuc
      if $DEBUG
        puts comment_form['comment']
      end
      result_page = comment_form.submit
      #puts result_page.body
    end
  end
end

