def niconico(video_id)
  str = <<EOF
<script type="text/javascript" src="http://www.nicovideo.jp/thumb_watch/#{video_id}?w=485&h=385"></script>
EOF

  return str
end

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'

  class TestGoogle < Test::Unit::TestCase
    def setup
    end

    def test_google
      assert_equal(%Q!<script type="text/javascript" src="http://www.nicovideo.jp/thumb_watch/sm281634?w=485&h=385"></script>\n!, niconico("sm281634"))
    end
  end
end

