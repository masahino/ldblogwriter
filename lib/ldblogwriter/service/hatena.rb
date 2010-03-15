# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'cgi'

require 'ldblogwriter/service/atompub.rb'

module LDBlogWriter
  module Service
  class Hatena < AtomPubClient
    def initialize(config)
      super(config.username, config.password, config.auth_type)
      @entry_uri = config.post_uri
      #get_resource_uri(@atom_client, @config.atom_pub_uri)
    end

    def post_entry(content, title, category = nil)
      return create_entry(@entry_uri, to_xml(content, title, category))
    end

    def edit_entry
    end

    def delete_entry
    end

    def post_image(image_file_path, image_title = nil)
      create_media(@image_uri, image_file_path)
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

    def get_resource_uri(atom_client, atom_uri)
      res_a = atom_client.get_resource_uri(atom_uri)
      @entry_uri = res_a[0]
      @image_uri = res_a[1]
    end

  end
end


end
