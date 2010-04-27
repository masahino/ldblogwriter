# -*- coding: utf-8 -*-
# livedoor PICSに登録した画像を貼り付ける

# APIの説明は、
# http://wiki.livedoor.jp/livedoor_pics/d/livedoor%20PICS%20WebService
# 
# 認証
# WSSEでlivedoor ID
#
# 新規投稿
# PostURL: http://ws.pics.livedoor.com/atom/<livedoor_id>
# に POST リクエストで XML 文書を送信する事で写真の登録が出来ます。

# 内容は、
# <?xml version="1.0" encoding="utf-8"?>
# <entry xmlns="http://purl.org/atom/ns#">
#   <title>KC380201.jpg</title>
#   <content mode="base64" type="image/jpeg">...</content>
# </entry>
# といった感じ。

# 使い方
# #pics(<画像ファイル名を指定>)
#   or
# #pics(<photo_id>)

# 新しく写真を登録して、表示する場合には、ファイル名を引数で指定する。
# 既に投稿済みの写真を表示する場合には、photo_idを指定する。

# 一旦投稿したあと、本文内容を編集して、再度blogを投稿すると、
# 既に画像を投稿済みなので、<error>Duplicate file</error>がコード400で
# 返ってきてしまう。
# そういう場合には、面倒だが、photo_idを調べて、そのIDを指定するようにする。

# 仮
module Livedoor
  module PICS
    def PICS::post
      puts "post"
    end
  end
end

def pics(arg_str)
  require 'uri'
  require 'net/http'
  require 'ldblogwriter/wsse'
  require 'ldblogwriter/atom_response'
  require 'pp'

  pics_root_uri = 'http://ws.pics.livedoor.com/atom/'
  
  if @conf.service != 'livedoor'
    return ""
  end

  raw_data = ""

  # 引数のタイプを判定
  # photo_id は7桁の数字
  if arg_str =~ /^\d{7}$/
    uri = URI.parse(pics_root_uri + @conf.username + "/" +arg_str) 
    puts uri
    Net::HTTP.start(uri.host, uri.port) do |http|
      res = http.get(uri.path, 
                     {'X-WSSE' => 
                       LDBlogWriter::Wsse::get(@conf.username, @conf.password),
                       'Content-Type' => 'application/x.atom+xml'})
      if res.code != '200'
        puts res.code
        res.each do |name, val|
          puts name + "->" + val
        end
        return res.body
      end
      atom_response = LDBlogWriter::AtomResponse.new(res.body)
      return atom_response.doc.elements['entry/content'].elements['div'][0]
    end
  else
    image_file_path = arg_str
    title = File.basename(image_file_path)
    begin
      open(image_file_path, 'rb') do |f|
        raw_data = f.read
      end
    rescue
      return "<!-- #{image_file_path} が見つかりません -->\n"
    end
  
    # 認証ユーザIDとパスワードは、livedoor IDを使う
    # それはusernameの筈
    uri = URI.parse(pics_root_uri + @conf.username)
    img_uri = ""
    Net::HTTP.start(uri.host, uri.port) do |http|
      data = <<EOF;
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://purl.org/atom/ns#">
<title>#{title}</title>
<content mode="base64" type="image/jpeg">
EOF
      data += [raw_data].pack('m')
      data += "</content>\n</entry>\n"
      res = http.post(uri.path, data,
                      {'X-WSSE' => 
                        LDBlogWriter::Wsse::get(@conf.username, @conf.password),
                        'Content-Type' => 'application/x.atom+xml'})
      if res.code != '201'
        puts res.code
        res.each do |name, val|
          puts name + "->" + val
        end
        return res.body
      end
      atom_response = LDBlogWriter::AtomResponse.new(res.body)
      return atom_response.doc.elements['entry/content'].elements['div'][0]
    end
  end
  return ""
end

