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
    ret = @ld.post_entry("this is pos test ", "test post entry", "test")
    assert_instance_of(String, ret)
    pp ret
  end

  def test_edit_entry
    edit_uri = @ld.post_entry("first post entry ", "test edit entry", "test")
    assert_instance_of(String, edit_uri)
    ret = @ld.edit_entry(edit_uri, "edited entry ", "test edit entry", "test")
    assert_instance_of(String, ret)
  end
end

