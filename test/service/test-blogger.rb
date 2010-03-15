$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'mocha'
require 'ldblogwriter/service/blogger.rb'
require 'ldblogwriter/config.rb'


class TestBlogger < Test::Unit::TestCase
  def setup
    config_file = ENV['HOME'] + "/ldblogwriter-blogger.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @service = LDBlogWriter::Service::Blogger::new(conf)
  end
  
  def test_authenticate
    request_ret = Net::HTTPResponse.new("1.1", "201", "hoge")
    Net::HTTP.any_instance.stubs(:request).returns(request_ret)
#    p @service.authenticate("user", "pass", nil)
  end

  def test_get_google_auth_token
    request_ret = Net::HTTPResponse.new("1.1", "201", "hoge")
    Net::HTTP.any_instance.stubs(:request).returns(request_ret)
#    p  @service.get_google_auth_token("user", "pass")
  end

  def test_to_xml
    request_ret = Net::HTTPResponse.new("1.1", "201", "hoge")
    Net::HTTP.any_instance.stubs(:request).returns(request_ret)
    assert(@service.to_xml("test content", "test title", "test"))
  end

  def test_post_entry
    post_ret = Net::HTTPResponse.new("1.1", "201", "hoge")
    post_ret['Location'] = "huga"
    Net::HTTP.any_instance.stubs(:post).returns(post_ret)
    ret = @service.post_entry("test content", "this is test", "test")
    assert_instance_of(String, ret)
  end
end

