# -*- coding: utf-8 -*-

require 'open-uri'
require 'pp'
require 'rexml/document'
require 'time'
require 'openssl'
require 'base64'

class AmazonECS

  SERVER_NAME = 'webservices.amazon.co.jp'
  SERVICE_URL = 'http://webservices.amazon.co.jp/onca/xml?' #Service=AWSECommerceService'
  def initialize(arg_hash)
    @access_key_id = arg_hash['access_key_id']
    @secret_access_key = arg_hash['secret_key_id']
  end

  def RFC3986_escape(str)
    # RFC3986
    safe_char = Regexp.new(/[A-Za-z0-9\-_.~]/)
    encoded = ""
    str.each_byte do|chr|
      if safe_char =~ chr.chr
        encoded = encoded + chr.chr
      else
        encoded = encoded + "%" + chr.chr.unpack("H*")[0].upcase
      end
    end
    return encoded
  end
  
  def get_signature(request_str, server = nil)
    if server == nil
      server = SERVER_NAME
    end
    message = ["GET", server, "/onca/xml", request_str].join("\n")
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, @secret_access_key, message)
    return RFC3986_escape(Base64.encode64(hash).chomp)
  end
  
  def item_lookup(asin)
    timestamp = RFC3986_escape(Time.now.iso8601)
    request_str = "Service=AWSECommeerceService" +
      "&AWSAccessKeyId=#{@access_key_id}" +
      "&Operation=ItemLookup" + 
      "&ResponseGroup=" + RFC3986_escape("Small,Images") +
      "&IdType=ASIN&ItemId=#{asin}" +
      "&Timestamp=#{timestamp}" +
      "&Version=2009-01-06"
    request_str = request_str.split("&").sort.join("&")
    signature = get_signature(request_str)
    request_str += "&Signature="+signature

    uri = SERVICE_URL+request_str

    item_h = Hash.new
    open(uri) do |f|
      response = f.gets

      response = REXML::Document.new(response)
      item = response.elements['ItemLookupResponse/Items/Item']
      if item.elements['DetailPageURL'] != nil
        item_h['DetailPageURL'] = item.elements['DetailPageURL'].get_text
      end
      if item.elements['MediumImage/URL'] != nil
        item_h['MediumImageURL'] = item.elements['MediumImage/URL'].get_text
      end
      if item.elements['ItemAttributes/Title'] != nil
        item_h['Title'] = item.elements['ItemAttributes/Title'].get_text
      end
      if item.elements['ItemAttributes/Author'] != nil
        item_h['Author'] = item.elements['ItemAttributes/Author'].get_text
      end
      if item.elements['ItemAttributes/Manufacturer'] != nil
        item_h['Manufacturer'] = item.elements['ItemAttributes/Manufacturer'].get_text
      end
    end
    return item_h
  end
end

# amazonのasinを指定して、その商品へのリンクを作成するプラグイン
# #asin(<ASIN>)
def asin(asin_str)
  access_key_id = @conf.options['amazon_access_key_id']
  secret_key_id = @conf.options['amazon_secret_key_id']
  if access_key_id == nil or secret_key_id == nil
    return
  end
  ecs = AmazonECS.new('access_key_id' => access_key_id,
                      'secret_key_id' => secret_key_id)
  item = ecs.item_lookup(asin_str)
  image_url_large = image_url_medium = nil
 
  result = ""
  result =  "<div class=\"amazon\">\n"
  result += "<div class=\"amazon-img\">\n"
  result += "<a href=\"#{item['DetailPageURL']}\">\n"
  if item['MediumImageURL'] != nil
    result += "<img src=\"#{item['MediumImageURL']}\" alt=\"#{item['Title']}\" /></a>\n"
  end
  result += "</div>\n"
  result += "『<a href=\"#{item['DetailPageURL']}\">#{item['Title']}</a>』<br />\n"
  if item['Author'] != nil
    result += "著者:#{item['Author']}<br />\n"
  end
  result += "#{item['Manufacturer']}<br />\n"
  result += "</div>\n"
  
  return result
end
