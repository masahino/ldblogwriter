$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'test/unit'
require 'ldblogwriter/config.rb'
require 'niconico.rb'

class TestPluginNicoNico < Test::Unit::TestCase
  def setup
    @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    end


    def test_niconico
      assert_equal(%Q!<script type="text/javascript" src="http://www.nicovideo.jp/thumb_watch/sm281634?w=485&h=385" charset="utf-8"></script>\n!, niconico("sm281634"))
    end

  
end
