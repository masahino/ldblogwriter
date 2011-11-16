$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'ldblogwriter/service/livedoor.rb'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/entry_manager.rb'


class TestLiveDoorGetEntry < Test::Unit::TestCase
  def setup
    config_file = ENV['HOME'] + "/.ldblogwriter.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @ld = LDBlogWriter::Service::LiveDoor::new(conf)
    @entry_manager = LDBlogWriter::EntryManager.new(conf.edit_uri_file)
  end
  
  def test_get_entry
     @ld.get_entry(@entry_manager.get_entries['20111116-1.txt'])
  end
end

