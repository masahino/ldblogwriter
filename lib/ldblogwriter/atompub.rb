# -*- coding: utf-8 -*-
require 'rexml/document'
require 'uri'
require 'net/http'
require 'shared-mime-info'
require 'mime/types'

require 'wsse.rb'
require 'atom_response.rb'

module LDBlogWriter

  class AtomPubClient
    attr_accessor :username, :password, :authtype

    def initialize(username, password, authtype=nil)
      @username = username
      @password = password
      @authtype = authtype
    end

    def get_service(service_uri)
    end

    def create_entry(uri, entry, title)
    end

    def create_media(uri_str, filename, title = nil)
      raw_data = ""
      begin
        File.open(filename, "rb") do |f|
          raw_data = f.read
        end
      rescue
        puts "Can't open #{filename}"
        exit
      end
      #type = `file -bi #{filename}`.chomp
#      mimetype = MIME.check(filename) 
      mimetype = MIME::Types.type_for(filename)[0].to_s

      if title == nil
        title = File.basename(filename)
      end
      
      puts uri_str
      uri = URI.parse(uri_str)
#      data = to_xml_image(title, type, raw_data)

      http_header = authenticate(@username, @password, @authtype)
      http_header = http_header.merge({"Content-type"=>mimetype,
                          "Content-length"=>raw_data.length.to_s,
                          "Slug"=>title})
      Net::HTTP.start(uri.host, uri.port) do |http|
        res = http.post(uri.path, raw_data,
                        http_header)
        if res.code != "201"
          puts res.body
          return false
        end
        img_uri = AtomResponse.new(res.body).media_src
p img_uri
        return img_uri
      end

    end

    def authenticate(username, password, authtype)
      send auth_method(authtype), username, password
    end

    private
    
    def auth_wsse(username, password)
      return {'X-WSSE' => Wsse::get(username, password)}
    end

    def auth_basic(username, password)
    end

    def auth_method(type)
      "auth_#{type.to_s.downcase}".intern
    end

    def to_xml_image(title, type, raw_data)
      data = <<EOF
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
    xmlns:app="http://www.w3.org/2007/app"
    xmlns:blogcms="http://blogcms.jp/-/atom">
EOF
#      data += "<title>#{title}</title>\n"
#      data += "<content type=\"#{type}\" mode=\"base64\">\n"
      data += "<content type=\"image/jpeg\" mode=\"base64\">"
      data += [raw_data].pack("m").chomp
      data += "</content>\n"
      data += "</entry>\n"
      return data
    end

  end
end


if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'
  require 'config.rb'
  require 'pp'

  class TestAtomPub < Test::Unit::TestCase
    def setup
      config_file = ENV['HOME'] + "/.ldblogwriter.conf"
      @conf = LDBlogWriter::Config.new(config_file)
      @atom = LDBlogWriter::AtomPubClient::new(@conf.username, @conf.password, :wsse)
    end
    
    def test_create_media
      @atom.create_media(@conf.atom_pub_uri+"blog/" + @conf.username+"/image",
                         "../../test/test.jpg", "test_image.jpg")
    end

  end
end

