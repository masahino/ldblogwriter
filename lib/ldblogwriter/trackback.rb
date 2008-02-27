require 'uri'

# trackbackを送るよ

module LDBlogWriter
  # title タイトル
  # excerpt 要約
  # url 記事URL
  # blog_name ブログタイトル
  class TrackBack
    def self::send(trackback_url, blog_name, title, excerpt, url) 
      uri = URI.parse(trackback_url)
      req = "title=#{title}&" + "excerpt=#{excerpt}&" +
        "url=#{url}&" + "blog_name=#{blog_name}"
      req = URI.encode(req)
      Net::HTTP.start(uri.host, uri.port) do |http|
        res = http.post(uri.path, req)
        puts res.body
      end
    end
  end
end
