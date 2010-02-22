# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'cgi'

require 'ldblogwriter/atompub.rb'

module LDBlogWriter
  class LiveDoor < AbstractService
    def initialize(config)
      super
      @atom_client = LDBlogWriter::AtomPubClient.new(config.username, config.password, :wsse)
      get_resource_uri(@atom_client, @config.atom_pub_uri)
    end

    def post_entry(conetent, title, category = nil)
      return @atom_client.create_entry(@entry_uri, to_xml(content, title, category))
    end

    def edit_entry
    end

    def delete_entry
    end

    def post_image(image_file_path, image_title = nil)
      @atom_client.create_media(@image_uri, image_file_path)
    end

    def to_xml(content, title, category = nil)
      data = <<EOF
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
    xmlns:app="http://www.w3.org/2007/app"
    xmlns:blogcms="http://blogcms.jp/-/atom">
EOF
      data += "<title>#{@title.chomp}</title>\n"

# #    <link rel="alternate" type="text/html" 
#        href="http://blog.livedoor.jp/staff/archives/000000.html" />
#     <link rel="edit" type="application/atom+xml;type=entry" 
#        href="http://livedoor.blogcms.jp/blog/staff/article/000000" title="Article Title" />
#     <id>tag:example.org,2003:3.2397</id>
#     <updated>2009-07-28T00:00:00+0900</updated>
#     <published>2009-07-28T00:00:00+0900</published>
#     <author><name>staff</name></author>

      data += "<content type=\"text/html\" xml:lang=\"ja\">\n"
#      data += [@content].pack("m").chomp
      data += CGI::escapeHTML(@content)
      data += "</content>\n"

      data += "<category scheme=\"http://livedoor.blogcms.jp/atom/blog/masahino123/category\" term=\"#{@category.chomp}\"/>\n"

#     <blogcms:source>
#         <blogcms:body><![CDATA[<p>記事本文</p>]]></blogcms:body>
#         <blogcms:more><![CDATA[<p>記事追記部分</p>]]></blogcms:more>
#         <blogcms:private><![CDATA[<p>記事プライベート部分</p>]]></blogcms:private>
#     </blogcms:source>
#     <app:control>
#         <app:draft>yes</app:draft>
#     </app:control>

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

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'
  require 'pp'

  require '../service.rb'
  require '../config.rb'
  require '../atom_response.rb'
  require '../atompub.rb'
  require '../wsse.rb'

  class TestLiveDoor < Test::Unit::TestCase
    def setup
      config_file = ENV['HOME'] + "/.ldblogwriter.conf"
      conf = LDBlogWriter::Config.new(config_file)
      @ld = LDBlogWriter::LiveDoor::new(conf)
    end

    def test_to_xml
      @ld.to_xml
    end


  end
end

