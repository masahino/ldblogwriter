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
  
  def test_to_xml
    assert(@sv.to_xml("test content", "test title", "test"))
  end

  def test_post_entry
    post_ret = Net::HTTPResponse.new("1.1", "201", "hoge")
    post_ret['Location'] = "huga"
#    Net::HTTP.any_instance.stubs(:post).returns(post_ret)
    ret = @sv.post_entry("test content", "this is test", "test")
    assert_instance_of(String, ret)
    pp ret
  end
end

