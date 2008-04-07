$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter/atom_response.rb'
require 'ldblogwriter/config.rb'

class TestAtomResponse < Test::Unit::TestCase
  def setup
    @test_xml =<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://purl.org/atom/ns#">
<title>test</title>
  <link rel="alternate" type="text/html" href="http://blog.livedoor.jp/bulknews/archives/00618.html"/>
  <link rel="service.edit" type="application/x.atom+xml" href="http://blog.livedoor.com/atom/blog_id=17/entry_id=618" title="test"/>
  <modified>2004-01-14T11:43:49Z</modified>
  <issued>2003-12-25T23:47:44+09:00</issued>
  <id>tag:blog.livedoor.jp,:bulknews.618</id>
  <summary type="text/plain">tetsts</summary>
  <subject/>
<content type="text/html" mode="escaped" xml:lang="ja" xml:base="http://blog.livedoor.jp/bulknews/archives/00618.html">
<![CDATA[tets]]>
</content>
<author><name>bulknews</name></author>
</entry>
EOF
  end

  # AtomResponse.uriは最初のURIを返す。
  def test_uri
    atom_response = LDBlogWriter::AtomResponse.new(@test_xml)
    assert_equal('http://blog.livedoor.jp/bulknews/archives/00618.html', atom_response.uri)
  end

  def test_title
    atom_response = LDBlogWriter::AtomResponse.new(@test_xml)
    assert_equal('test', atom_response.title)
  end
end
