$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/parser.rb'
require 'ldblogwriter/entry.rb'

class TestEntry < Test::Unit::TestCase
  def setup
    @conf = LDBlogWriter::Config.new('test.conf')
    @parser = LDBlogWriter::Parser.new(@conf, nil)
  end

  def test_initialize
    entry = LDBlogWriter::BlogEntry.new(@conf, "test")
    assert_equal("test", entry.title)
    assert_equal(nil, entry.category)
    assert_equal("", entry.content)
    entry = LDBlogWriter::BlogEntry.new(@conf, "test2", "hoge", "huga")
    assert_equal("test2", entry.title)
    assert_equal("hoge", entry.category)
    assert_equal("huga", entry.content)
  end

  def test_to_xml
    # no category, no contents
    entry = LDBlogWriter::BlogEntry.new(@conf, "test")
    assert_equal(%Q!<entry xmlns="http://purl.org/atom/ns#">\n<title xmlns="http://purl.org/atom/ns#">test</title>\n<subject xmlns="http://purl.org/dc/elements/1.1/"></subject>\n<content xmlns="http://purl.org/atom/ns#" mode="base64"></content>\n</entry>\n!, entry.to_xml)
    # category, contents
    entry2 = LDBlogWriter::BlogEntry.new(@conf, "test2", "category", "content")
    assert_equal(%Q!<entry xmlns="http://purl.org/atom/ns#">\n<title xmlns="http://purl.org/atom/ns#">test2</title>\n<subject xmlns="http://purl.org/dc/elements/1.1/">category</subject>\n<content xmlns="http://purl.org/atom/ns#" mode="base64">Y29udGVudA==\n</content>\n</entry>\n!, entry2.to_xml)
  end

  def test_get_entry_info
    
  end

  def test_to_xml_livedoor
  end

  def test_to_xml_blogger
  end

end


class TestUploadEntry  < Test::Unit::TestCase
  def test_to_xml
  end
end
