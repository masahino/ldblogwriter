# -*- coding: utf-8 -*-

$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'pics.rb'

class TestPluginPics < Test::Unit::TestCase
  def setup
    @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    end

    # livedoor Blogの場合のみ有効
    # @conf['service']がlivedoorのときのみ
    # それ以外の場合には、何もせず空白文字列を返す
    def test_service
      @conf.service = 'blogger'
      assert_equal("", pics('dummy_path'))
    end

    # 引数で指定したファイルが見つからなければ、
    # エラーメッセージをHTMLのコメント形式で返す。
    def test_no_such_file
      assert_equal("<!-- dummy_path が見つかりません -->\n", pics('dummy_path'))
    end

    # 投稿に失敗した場合、
    # エラーメッセージをHTMlのコメント形式で返す。
    def test_post_failure
      assert_equal(false, pics('pics.rb'))
    end

    # 投稿に成功したら、
    # responseから画像のURLが分かる筈
    def test_post
      @conf = LDBlogWriter::Config.new(ENV['HOME'] + '/.ldblogwriter.conf')
      puts pics('test1.jpg')
    end

  
end
