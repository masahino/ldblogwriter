# -*- coding: utf-8 -*-
require 'rubygems'
require 'pp'
module Booklog
  class Agent
    require 'mechanize'
    require 'kconv'

    BooklogHomeURI = 'http://booklog.jp'
    BooklogLoginURI = 'http://booklog.jp/login'
    BooklogInputURI = 'http://booklog.jp/input'
    def initialize(user_id, password)
      @agent = WWW::Mechanize.new
      @agent.post_connect_hooks << lambda{|params| params[:response_body] = NKF.nkf('-w8m0', params[:response_body])}

      authentication(@agent, user_id, password)
    end

    def authentication(agent, user_id, password)
      login_page = agent.get(BooklogLoginURI)
#      login_form = login_page.forms.with.action("./uhome.php").first
      login_form = login_page.form_with(:name => 'frm')
      login_form.account = user_id
      login_form.password = password
      result_page = login_form.submit
    end

    # ISBNによる登録
    def input(isbn_list)
      input_page = @agent.get(BooklogInputURI)
      input_form = input_page.form_with(:action => BooklogInputURI)
      input_form['isbns'] = isbn_list.join("\n")
#      result_page = input_form.submit
      result_page = input_form['buttons'].click
      pp result_page
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

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'
  require 'ldblogwriter'

  class TestBooklog < Test::Unit::TestCase
    def setup
      # login idとpasswordを代入
      lbw = LDBlogWriter::Blog.new
      @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    end

    def test_authentication
      Booklog::Agent.new(@config.options['booklog_userid'], @config.options['booklog_password'])
    end

    def test_input
      agent = Booklog::Agent.new(@config.options['booklog_userid'], @config.options['booklog_password'])
      agent.input(['4480426280'])
    end
  end
end
