$LOAD_PATH.unshift 'lib'

require 'test/unit'

require 'ldblogwriter/entry_manager.rb'
require 'ldblogwriter/config.rb'


class TestEntryManager < Test::Unit::TestCase
  def setup
    config_file = "test/test.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @em = LDBlogWriter::EntryManager.new("test/test.yaml")
  end
  
  def test_save_edit_uri
    @em.save_edit_uri("test.txt", "http://example.com/hoge")
  end

  def test_save_html_file
  end

  def test_get_entries
#    p @em.get_entries
  end
end

