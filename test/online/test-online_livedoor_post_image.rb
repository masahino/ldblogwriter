$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'ldblogwriter/service/livedoor.rb'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/entry_manager.rb'


class TestLiveDoorPostImage < Test::Unit::TestCase
  def setup
    config_file = ENV['HOME'] + "/.ldblogwriter.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @ld = LDBlogWriter::Service::LiveDoor::new(conf)
  end
  
  def test_post_image
    ret = @ld.post_image("test/test.jpg", "test image")
    pp ret
  end
end

