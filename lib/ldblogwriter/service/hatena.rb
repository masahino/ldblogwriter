# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'cgi'

require 'ldblogwriter/service/atompub.rb'

module LDBlogWriter
  module Service
  class Hatena < AtomPubClient
    HATENA_FOTO_POST_URI='http://f.hatena.ne.jp/atom/post'

    def initialize(config)
      super(config.username, config.password, config.auth_type)
      @entry_uri = config.atompub_uri
      #get_resource_uri(@atom_client, @config.atom_pub_uri)
    end

    def post_entry(content, title, category = nil)
      return create_entry(@entry_uri, to_xml(content, title, category))
    end

    def edit_entry
    end

    def delete_entry
    end

    def post_image(filename, image_title = nil)
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
      data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
      data += "<entry xmlns=\"http://purl.org/atom/ns#\">\n"
      data += "<title>#{image_title.chomp}</title>\n"
      data += "<content mode=\"base64\" type=\"#{mimetype}\">\n"
      data += [raw_data].pack("m")
      data += "</content>\n"
      data += "</entry>\n"
      return create_entry(HATENA_FOTO_POST_URI, data)
    end

    def to_xml(content, title, category = nil)
      data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
      data += "<entry xmlns=\"http://purl.org/atom/ns#\">\n"
      data += "<title>#{title.chomp}</title>\n"
      data += "<content type=\"text/plain\">\n"
      data += content
      data += "</content>\n"
      data += "</entry>\n"
      return data
    end

    private

  end
end


end
