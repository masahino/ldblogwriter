$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'mocha'
require 'ldblogwriter/entry_manager.rb'
require 'ldblogwriter/config.rb'


class TestEntryManager < Test::Unit::TestCase
  def setup
#    config_file = ENV['HOME'] + "/.ldblogwriter.conf"
    config_file = "test/test.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @em = LDBlogWriter::EntryManager.new(conf)
  end
  
  def test_save_edit_uri
    @em.save_edit_uri("test.txt", "http://example.com/hoge")
  end

  def test_save_html_file
  end
end

