$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'mocha'
require 'ldblogwriter/service/hatena.rb'
require 'ldblogwriter/config.rb'


class TestHatena < Test::Unit::TestCase
  def setup
    config_file = ENV['HOME'] + "/ldblogwriter-hatena.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @sv = LDBlogWriter::Service::Hatena::new(conf)
  end
  
  def test_post_image
    post_ret = Net::HTTPResponse.new("1.1", "201", "hoge")
    post_ret['Location'] = "huga"
    ret = @sv.post_image("test/test.jpg", "test image")
    pp ret
  end
end

