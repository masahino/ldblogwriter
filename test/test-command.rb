$LOAD_PATH.unshift '../lib'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/command.rb'

class TestCommand < Test::Unit::TestCase
  def setup
  end

  def test_get_auth_info
    com = LDBlogWriter::Command.new('hoge')
    assert_raise(ArgumentError) {com.get_auth_info("hoge", "huga")}

    com = LDBlogWriter::Command.new
    assert_equal('wsse', com.auth_type)
    ret = com.get_auth_info("hoge", "huga")
    assert_equal('X-WSSE', ret.keys[0])

    com = LDBlogWriter::Command.new('google')
    assert_equal('google', com.auth_type)
    ret = com.get_auth_info("hoge", "huga")
    assert_equal('Authentication', ret.keys[0])
  end

end
