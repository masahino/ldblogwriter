require 'test/unit'
require 'config.rb'
require 'command.rb'


module LDBlogWriter
  class Command
    def upload(atom_uri, user, pass, filename, title = nil)
      return 'http://image.blog.livedoor.jp/test_user/imgs/8/a/8a4d2846.jpg'
    end
  end
end

class TestCommand < Test::Unit::TestCase
  def setup
  end

  def test_get
  end
end
