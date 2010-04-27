$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'ldblogwriter/service/livedoor.rb'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/entry_manager.rb'


class TestLiveDoorPostEntry < Test::Unit::TestCase
  def setup
    config_file = ENV['HOME'] + "/.ldblogwriter.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @ld = LDBlogWriter::Service::LiveDoor::new(conf)
  end
  
  def test_post_entry
    ret = @ld.post_entry("test post entry ", "this is test", "test")
    assert_instance_of(String, ret)
    pp ret
  end
end

