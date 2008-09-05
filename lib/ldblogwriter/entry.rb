# -*- coding: utf-8 -*-
module LDBlogWriter
  class BlogEntry
    attr_accessor :title, :category, :content
    attr_accessor :summary, :alternate
    attr_accessor :send_tb
    attr_accessor :trackback_url_array
    attr_accessor :edit_uri
    def initialize(conf, title, category = nil, content = "")
      @conf = conf
      @title = title
      @category = category
      @content = content
      @send_tb = false
      @trackback_url_array = []
    end
    
    def to_xml_livedoor
      data = "<entry xmlns=\"http://purl.org/atom/ns#\">\n"
      data += "<title xmlns=\"http://purl.org/atom/ns#\">#{@title.chomp}</title>\n"
      # カテゴリーは1つしか指定できないみたい
      #    categories.each do |category|
      #      data += "<subject xmlns=\"http://purl.org/dc/elements/1.1/\">#{category}</subject>\n"
      #    end
      data += "<subject xmlns=\"http://purl.org/dc/elements/1.1/\">#{@category.chomp}</subject>\n"
      data += "<content xmlns=\"http://purl.org/atom/ns#\" mode=\"base64\">"
      data += [@content].pack("m").chomp
      data += "</content>\n"
      data += "</entry>\n"
      return data
    end

    def to_xml_blogger
      data = "<entry xmlns='http://www.w3.org/2005/Atom'>\n"
      data += "<title type='text'>#{@title}</title>\n"
      data += "<content type='xhtml'>\n"
      data += "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n"
      data += @content
      data += "</div>\n"
      data += "</content>\n"
      data += "<author>\n"
      data += "<name>#{@conf.username}</name>\n"
      data += "<email>#{@conf.username}</email>\n"
      data += "</author>\n"
      data += "</entry>\n"
      return data
    end

    def to_xml_hatena
      data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
      data += "<entry xmlns=\"http://purl.org/atom/ns#\">\n"
      data += "<title>#{@title.chomp}</title>\n"
      data += "<content type=\"text/plain\">\n"
      data += content
      data += "</content>\n"
      data += "</entry>\n"
      return data
    end
      

    def to_xml
      case @conf.service
      when 'livedoor'
        to_xml_livedoor
      when 'blogger'
        to_xml_blogger
      when 'hatena'
        to_xml_hatena
      else
        raise 'unkown service: #{@conf.service}'
      end
    end

    def get_entry_info(edit_uri)
      @edit_uri = edit_uri
      entry_info = Command.new.get(edit_uri, @conf.username, @conf.password)
      entry_info.doc.elements.each('entry/title') do |e|
        if $DEBUG
          puts "title:" + e.text
        end
      end
      entry_info.doc.elements.each('entry/summary') do |e|
        if $DEBUG
          puts "summary: " + e.text
        end
        @summary = e.text
      end
      entry_info.doc.elements.each('entry/link') do |e|
        if e.attributes['rel'] == 'alternate'
          if $DEBUG
            puts "href=" + e.attributes['href']
          end
          @alternate = e.attributes['href']
        end
      end
      
    end

  end

  class UploadEntry
    def initialize(title, filename)
      @title = title
      @filename = filename
      @raw_data = ""
      begin
        File.open(filename, "rb") do |f|
          @raw_data = f.read
        end
      rescue
        puts "Can't open #{filename}"
        exit
      end
      @type = `file -bi #{filename}`.chomp
    end
    
    def to_xml
      data = "<entry xmlns=\"http://purl.org/atom/ns#\">\n"
      data += "<title xmlns=\"http://purl.org/atom/ns#\">#{@title}</title>\n"
      data += "<filename xmlns=\"http://purl.org/atom/ns#\">#{@filename}</filename>\n"
      data += "<content xmlns=\"http://purl.org/atom/ns#\" type=\"#{@type}\" mode=\"base64\">"
      data += [@raw_data].pack("m")
      data += "</content>\n"
      data += "</entry>\n"
      return data
    end
  end
end
