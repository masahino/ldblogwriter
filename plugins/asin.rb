require 'amazon/search'
require 'open-uri'

# amazonのasinを指定して、その商品へのリンクを作成するプラグイン
# #asin(<ASIN>)
def asin(asin_str)
  amazon_token = @conf.options['amazon_dev_token']
  amazon_id = @conf.options['amazon_assoc_id']
  if amazon_token == nil or amazon_id == nil
    return
  end
  cache_dir = ENV['HOME'] + "/.amazon_cache"
  request = Amazon::Search::Request.new(amazon_token,
                                        amazon_id,
                                        "jp", false)
  request.cache = Amazon::Search::Cache.new(cache_dir)
  image_url_large = image_url_medium = nil
  url = nil
  title = nil
  author = artist = nil
  manufacturer = nil
  release_date = nil
  request.asin_search(asin_str.to_s) do |product|
    begin
      title = product.product_name
    rescue
      title = "error!!"
    end
    url = product.url.gsub(/(http:.*\/#{amazon_id})\?.*/) do |u|
      $1 + "/ref=nosim"
    end
    image_size = 0

    if product.image_url_medium == nil
      image_url_large = image_url_medium = nil
    else        
      open(product.image_url_medium) do |f|
        image_size = f.length
      end
      if image_size != 807 
        image_url_large = product.image_url_large
        image_url_medium = product.image_url_medium
      else
        image_url_large = image_url_medium = nil
      end
    end
    if product.authors != nil
      author = product.authors.join("/")  
    elsif product.artists != nil
      artist = product.artists.join("/")
    end            
    manufacturer = product.manufacturer
    release_date = product.release_date
  end

  result = ""
  result =  "<div class=\"amazon\">\n"
  result += "<div class=\"amazon-img\">\n"
  if image_url_large != nil
    result += "<a href=\"#{url}\">\n"
    result += "<img src=\"#{image_url_medium}\" alt=\"#{title}\" /></a>\n"
  else
    # image ないとき
    #result += @diary.config['NO_IMAGE_FILE']
  end
  result += "</div>\n"
  result += "『<a href=\"#{url}\">#{title}</a>』<br />\n"
  if author != nil
    result += "著者:#{author}<br />\n"
  elsif artist != nil
    result += "アーティスト:#{artist}<br />\n"
  end            
  result += "#{manufacturer}<br />\n"
  result += "発売日:#{release_date}<br />\n"
  result += "</div>\n"
  #          result += "<p>"
  
  return result
end

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'

  class TestAsin < Test::Unit::TestCase
    def setup
    end

  end
end
