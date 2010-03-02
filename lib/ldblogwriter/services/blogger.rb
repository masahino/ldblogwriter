# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'cgi'

require 'ldblogwriter/atompub.rb'
require 'ldblogwriter/service.rb'

module LDBlogWriter
  class Blogger < AbstractService


    def initialize(config)
      super
      @atom_client = LDBlogWriter::AtomPubClient.new(config.username, config.password, :google)
#      get_resource_uri(@atom_client, @config.atom_pub_uri)
      @entry_uri = config.post_uri
    end

    def post_entry(content, title, category = nil)
      return @atom_client.create_entry(@entry_uri, 
                                       to_xml(content, title, category))
    end

    def edit_entry
    end

    def delete_entry
    end

    def post_image(image_file_path, image_title = nil)
      @atom_client.create_media(@image_uri, image_file_path)
    end

    def to_xml(content, title, category = nil)
      data = "<entry xmlns='http://www.w3.org/2005/Atom'>\n"
      data += "<title type='text'>#{title}</title>\n"
      data += "<content type='xhtml'>\n"
      data += "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n"
      data += content
      data += "</div>\n"
      data += "</content>\n"
      data += "<author>\n"
#      data += "<name>#{@conf.username}</name>\n"
#      data += "<email>#{@conf.username}</email>\n"
      data += "</author>\n"
      data += "</entry>\n"
      return data
    end

    private

    def get_resource_uri(atom_client, atom_uri)
      res_a = atom_client.get_resource_uri(atom_uri)
#      @entry_uri = res_a[0]
#      @image_uri = res_a[1]
    end
  end
end


