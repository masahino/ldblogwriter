# -*- coding: utf-8 -*-

# Stack Stock Booksの情報更新
# #stack(<ASIN>, <STATE>)
# stateは、"unread"|"reading"|"read"|"wish"
# 利用者IDとAPIトークンは設定ファイルで指定
# @options['stack_api_token']
# @options['stack_id']
def stack(asin, state)
  require 'net/http'
  require 'yaml'
  require 'uri'
  require 'date'

  user = @conf.options['stack_id']
  token = @conf.options['stack_api_token']
  Net::HTTP.version_1_2
  update_uri_str = "http://stack.nayutaya.jp/api/#{user}/#{token}/stocks/update.1"
  uri = URI.parse(update_uri_str)
  book_info = Hash.new
  book_info['asin'] = asin
  book_info['date'] = Date.today.to_s
  book_info['state'] = state
  puts update_uri_str
  Net::HTTP.start(uri.host, uri.port) do |http|
    response = http.post(uri.path, "request=#{URI.encode([book_info].to_yaml)}")
    # error処理
    p response.body
  end
  ""
end

def stack_post(asin, state)
  require 'stack_stock_books'

  user = @conf.options['stack_id']
  op_server = @conf.options['stack_op_server']
  op_id = @conf.options['stack_op_id']
  op_password = @conf.options['stack_op_password']
  
  stack = StackStockBooks::Agent.new(user, op_server, op_id, op_password)
  
  stack.edit_note(asin, @entry.alternate)
end

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'
  require 'ldblogwriter/config'


  class TestStack < Test::Unit::TestCase
    def setup
      @conf = LDBlogWriter::Config.new()
    end

    # 利用者IDとAPIトークンが設定されてなければ、エラー
    def test_config
    end
    
    # asinとstateのチェック
    def test_args
    end

  end
end


