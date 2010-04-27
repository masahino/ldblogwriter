$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'ldblogwriter/service/livedoor.rb'
require 'ldblogwriter/config.rb'


class TestLiveDoorGetEntries < Test::Unit::TestCase
  def setup
    config_file = ENV['HOME'] + "/.ldblogwriter.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @ld = LDBlogWriter::Service::LiveDoor::new(conf)
  end
  
  def test_get_entries
    @ld.get_entries
  end
  
end

