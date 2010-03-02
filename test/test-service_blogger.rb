$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'mocha'
require 'ldblogwriter/services/blogger.rb'
require 'ldblogwriter/config.rb'


class TestLiveDoor < Test::Unit::TestCase
  def setup
    config_file = ENV['HOME'] + "/.ldblogwriter.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @ld = LDBlogWriter::Blogger::new(conf)
  end
  
  def test_to_xml
    assert(@ld.to_xml("test content", "test title", "test"))
  end

  def test_post_entry
    post_ret = Net::HTTPResponse.new("1.1", "201", "hoge")
    post_ret['Location'] = "huga"
    Net::HTTP.any_instance.stubs(:post).returns(post_ret)
    ret = @ld.post_entry("test content", "this is test", "test")
    assert_instance_of(String, ret)
  end
end

