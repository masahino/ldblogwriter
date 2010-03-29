$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/parser.rb'
require 'ldblogwriter/entry.rb'

class TestEntry < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new('test/test.conf')
    @parser = LDBlogWriter::Parser.new(@conf, nil)
  end

  def test_initialize
    entry = LDBlogWriter::BlogEntry.new("test")
    assert_equal("test", entry.title)
    assert_equal(nil, entry.category)
    assert_equal("", entry.content)
    entry = LDBlogWriter::BlogEntry.new("test2", "hoge", "huga")
    assert_equal("test2", entry.title)
    assert_equal("hoge", entry.category)
    assert_equal("huga", entry.content)
  end


  def test_get_entry_info
    
  end


end


class TestUploadEntry  < Test::Unit::TestCase
  def test_to_xml
  end
end
