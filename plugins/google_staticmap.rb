# 基本構文は、http: //maps.google.com/staticmap?parameters です。この parameters の部分に位置情報やマップのサイズ、マーカー情報などを指定します。使用できるパラメータには次のものがあります。

# ・center（ 必須 ）： マップの中央の座標を緯度と経度で指定します。 （ 例 ：center=35.65641,139.699477）
# ・zoom（ 必須 ）： ズームレベルを 0 ～ 19 の間で指定します。 （例：zoom=13）
# ・size（ 必須 ）： 表示するマップのサイズを幅 × 高さで指定します。なお、指定できる地図の最大の大きさは 512x512 です。
# ・maptype （オプション ）： マップ の表示タイプを指定します。値は roadmap と mobile の 2 種類で、roadmap は標準のマップ表示、 mobile は携帯用に見やすくした表示となります。 roadmap がデフォルトとなります。
# ・markers（オプション ）： マーカーをマップ上に配置します。マーカーを指定した場合、 center や zoom は指定しなくても構いません。指定できる内容は、マーカーの緯度・経度、マーカーの色 （red,blue,green） 、マーカーの文字（a-z）を指定できます。また、複数のマーカーを指 定するときは、|（パイプ、%7C ） で区切ります。
# ・key（ 必須 ）：Google Maps API キーを指定します。

def google_staticmap(longitude, latitude, zoom=13)
  #zoom = 13
  # size = 485, 385
  # key
  str = <<EOF
<img src="http://maps.google.com/staticmap?center=#{longitude},#{latitude}&zoom=13&size=425x350&key=#{@conf.options['google_maps_api_key']}">
EOF

  return str
end

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'
  require 'ldblogwriter/config'

  class TestGoogleStaticMap < Test::Unit::TestCase
    def setup
      @conf = LDBlogWriter::Config.new(ENV['HOME']+"/.ldblogwriter.conf")
    end

    def test_google_staticmap
      assert_equal(%Q!<script type="text/javascript" src="http://www.nicovideo.jp/thumb_watch/sm281634?w=485&h=385"></script>\n!, google_staticmap(35.688394,139.77132))
    end
  end
end

