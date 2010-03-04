# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'cgi'

require 'ldblogwriter/service/atompub.rb'
require 'ldblogwriter/atom_response.rb'

module LDBlogWriter
  module Service
    class LiveDoor < AtomPubClient
      def initialize(config)
        super(config.username, config.password, config.auth_type)
        res = get_resource_uri(config.atom_pub_uri)
        @entry_uri = res.collection_uri[0]
        @image_uri = res.collection_uri[1]
      end

      def to_xml(content, title, category = nil)
        data = <<EOF
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
    xmlns:app="http://www.w3.org/2007/app"
    xmlns:blogcms="http://blogcms.jp/-/atom">
EOF
        data += "<title>#{title.chomp}</title>\n"
        data += "<content type=\"text/html\" xml:lang=\"ja\">\n"
        data += CGI::escapeHTML(content)
        data += "</content>\n"

        if category != nil
          data += "<category scheme=\"http://livedoor.blogcms.jp/atom/blog/masahino123/category\" term=\"#{category.chomp}\"/>\n"
        end
        data += "</entry>\n"
        return data
      end

    end
  end
end


