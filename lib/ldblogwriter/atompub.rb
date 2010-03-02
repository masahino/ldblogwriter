# -*- coding: utf-8 -*-
require 'rexml/document'
require 'uri'
require 'net/http'
require 'net/https'

require 'ldblogwriter/wsse.rb'
require 'ldblogwriter/atom_response.rb'

module LDBlogWriter
  class AtomPubClient
    attr_accessor :username, :password, :authtype

    GOOGLE_LOGIN_URL = 'https://www.google.com/accounts/ClientLogin'

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
        return AtomResponse.new(res.body)
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

    def auth_google(username, password)
      return {'Authorization' => 'GoogleLogin auth='+
        get_google_auth_token(username, password)}
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

    private
    
    def get_google_auth_token(username, password)
      url = URI.parse(GOOGLE_LOGIN_URL)
      req = Net::HTTP::Post.new(url.path)
      
      req.form_data = {'Email' => username,
        'Passwd' => password,
        'service' => 'blogger', 
        'accountType' => 'GOOGLE',
        'source' => "hoge-lbw-1"}
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      https.cert_store = store
      https.start do
        res = https.request(req)
        if res.body =~ /Auth=(.+)/
          return $1
        else
          puts res.body
        end
      end
      return nil
    end

  end
end


