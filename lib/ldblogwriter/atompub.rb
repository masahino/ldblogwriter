# -*- coding: utf-8 -*-
require 'rexml/document'
require 'uri'
require 'net/http'

require 'ldblogwriter/wsse.rb'
require 'ldblogwriter/atom_response.rb'

module LDBlogWriter
  class AtomPubClient
    attr_accessor :username, :password, :authtype

    def initialize(username, password, authtype=nil)
      @username = username
      @password = password
      @authtype = authtype
    end

    def get_resource_uri(uri_str)
      uri = URI.parse(uri_str)
      Net::HTTP.start(uri.host, uri.port) do |http|
        res = http.get(uri.path,
                       authenticate(@username, @password, @authtype))
        if res.code != "200"
          puts res.body
          return false
        end
        return AtomResponse.new(res.body).collection_uri
      end
    end

    def create_entry(uri_str, entry_xml)
      if $DEBUG
        puts uri_str
      end
      uri = URI.parse(uri_str)
      Net::HTTP.start(uri.host, uri.port) do |http|
        res = http.post(uri.path, entry_xml,
                        authenticate(@username, @password, @authtype).update({'Content-Type' => 'application/atom+xml'}))
        case res.code
        when "201"
          edit_uri = res['Location']
        when "404"
          puts res.body
          edit_uri = false
        when "200"
          puts res.body
          edit_uri = false
        else
          puts "return code: " + res.code
          puts "response: " + res.body
          edit_uri = false
        end
        return edit_uri
      end
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
      mimetype = get_mimetype(filename)

      if title == nil
        title = File.basename(filename)
      end
      
      uri = URI.parse(uri_str)

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
        return img_uri
      end
    end

    def authenticate(username, password, authtype)
      send auth_method(authtype), username, password
    end

    private
    
    def auth_wsse(username, password)
      return {'X-WSSE' => LDBlogWriter::Wsse::get(username, password)}
    end

    def auth_basic(username, password)
    end

    def auth_method(type)
      "auth_#{type.to_s.downcase}".intern
    end

    def get_mimetype(filename)
      begin
        require 'mime/types'
        return MIME::Types.type_for(filename)[0].to_s
      rescue
        return `file -bi #{filename}`.chomp
      end
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
#      @atom.create_media(@conf.atom_pub_uri+"blog/" + @conf.username+"/image",
#                         "../../test/test.jpg", "test_image.jpg")
    end

    def test_get_resource_uri
      uri_a = @atom.get_resource_uri(@conf.atom_pub_uri)
    end
  end
end

