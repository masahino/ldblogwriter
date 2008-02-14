#require 'amazon/search'
#require 'net/http'
require 'open-uri'
require 'pp'
require 'rexml/document'

#Net::HTTP.version_1_2

class AmazonECS

  SERVICE_URL = 'http://webservices.amazon.co.jp/onca/xml?Service=AWSECommerceService'
  def initialize(arg_hash)
    @subscription_id = arg_hash['subscription_id']
    @associate_tag = arg_hash['associate_tag']
    @base_url = SERVICE_URL + "&SubscriptionId=#{@subscription_id}&AssociateTag=#{@associate_tag}"
  end
  
  def item_lookup(asin)
    uri = @base_url + "&Operation=ItemLookup" + "&ResponseGroup=Small,Images" +
      "&IdType=ASIN&ItemId=#{asin}"
    item_h = Hash.new
    open(uri) do |f|
      response = f.gets
      response = REXML::Document.new(response)
      item = response.elements['ItemLookupResponse/Items/Item']
      item_h['DetailPageURL'] = item.elements['DetailPageURL'].get_text
      item_h['MediumImageURL'] = item.elements['MediumImage/URL'].get_text
      item_h['Title'] = item.elements['ItemAttributes/Title'].get_text
      item_h['Author'] = item.elements['ItemAttributes/Author'].get_text
      item_h['Manufacturer'] = item.elements['ItemAttributes/Manufacturer'].get_text
    end
    return item_h
  end
end

# amazonのasinを指定して、その商品へのリンクを作成するプラグイン
# #asin(<ASIN>)
def asin(asin_str)
  sub_id = @conf.options['amazon_sub_id']
  assoc_id = @conf.options['amazon_assoc_id']
  if sub_id == nil or assoc_id == nil
    return
  end
#  cache_dir = ENV['HOME'] + "/.amazon_cache"
  ecs = AmazonECS.new('subscription_id' => sub_id,
                      'associate_tag' => assoc_id)
  item = ecs.item_lookup(asin_str)
  image_url_large = image_url_medium = nil
 
  result = ""
  result =  "<div class=\"amazon\">\n"
  result += "<div class=\"amazon-img\">\n"
  result += "<a href=\"#{item['DetailPageURL']}\">\n"
  result += "<img src=\"#{item['MediumImageURL']}\" alt=\"#{item['Title']}\" /></a>\n"
  result += "</div>\n"
  result += "『<a href=\"#{item['DetailPageURL']}\">#{item['Title']}</a>』<br />\n"
#  if author != nil
    result += "著者:#{item['Author']}<br />\n"
#  elsif artist != nil
#    result += "アーティスト:#{artist}<br />\n"
#  end            
  result += "#{item['Manufacturer']}<br />\n"
#  result += "発売日:#{release_date}<br />\n"
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
