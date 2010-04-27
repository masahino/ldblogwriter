$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'mocha'
require 'ldblogwriter/service/hatena.rb'
require 'ldblogwriter/config.rb'

class TestHatena < Test::Unit::TestCase
  def setup
#    config_file = ENV['HOME'] + "/ldblogwriter-hatena.conf"
    config_file = 'test/online/hatena.conf'
    @conf = LDBlogWriter::Config.new(config_file)
    @conf.username = ARGV[0]
    @conf.password = ARGV[1]
    @conf.atompub_uri = "http://d.hatena.ne.jp/#{@conf.username}/atom/blog"
    @sv = LDBlogWriter::Service::Hatena::new(@conf)
  end
  
  def test_to_xml
    assert(@sv.to_xml("test content", "test title", "test"))
  end

  def test_post_entry
    ret = @sv.post_entry("test content", "this is test", "test")
    assert_instance_of(String, ret)
  end
end

