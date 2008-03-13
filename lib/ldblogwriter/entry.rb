module LDBlogWriter
  class BlogEntry
    attr_accessor :title, :category, :content
    attr_accessor :summary, :alternate
    attr_accessor :send_tb
    attr_accessor :trackback_url_array
    def initialize(conf, title, category = nil, content = "")
      @conf = conf
      @title = title
      @category = category
      @content = content
      @send_tb = false
      @trackback_url_array = []
    end
    
    def to_xml
      data = "<entry xmlns=\"http://purl.org/atom/ns#\">\n"
      data += "<title xmlns=\"http://purl.org/atom/ns#\">#{@title}</title>\n"
      # カテゴリーは1つしか指定できないみたい
      #    categories.each do |category|
      #      data += "<subject xmlns=\"http://purl.org/dc/elements/1.1/\">#{category}</subject>\n"
      #    end
      data += "<subject xmlns=\"http://purl.org/dc/elements/1.1/\">#{@category}</subject>\n"
      data += "<content xmlns=\"http://purl.org/atom/ns#\" mode=\"base64\">"
      data += [@content].pack("m")
      data += "</content>\n"
      data += "</entry>\n"
      return data
    end

    def get_entry_info(edit_uri)
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
