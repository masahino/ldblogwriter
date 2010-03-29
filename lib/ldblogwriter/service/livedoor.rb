# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'cgi'
require 'rexml/document'
require 'time'

require 'ldblogwriter/service/atompub.rb'
require 'ldblogwriter/atom_response.rb'
require 'ldblogwriter/entry.rb'

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

      def get_entries
        entries = Array.new
        uri = URI.parse(@entry_uri)
        Net::HTTP.start(uri.host, uri.port) do |http|
          res = http.get(uri.path,
                         authenticate(@username, @password, @authtype))
          source = res.body
          if source.respond_to?('force_encoding')
            source.force_encoding('UTF-8')
          end
          doc = REXML::Document.new(source)
          doc.each_element("/feed/entry") do |e|
            title = e.elements["title"].text
            category = e.elements["//category"].attributes["term"]
            entry = LDBlogWriter::BlogEntry.new(title, category)
            entry.updated_time = Time::parse(e.elements["updated"].text)
            entry.published_time = Time::parse(e.elements["published"].text)
            entry.alternate_uri = e.elements["link[@rel='alternate']"].attributes["href"]
            entry.edit_uri = e.elements["link[@rel='edit']"].attributes["href"]
            entries.push(entry)
          end
        end
        entries
      end
    end
  end
end


