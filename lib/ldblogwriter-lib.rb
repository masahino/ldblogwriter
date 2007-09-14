$LOAD_PATH.unshift "../lib"

require 'net/http'
require 'rexml/document'
require 'pp'
require 'uri'
require 'yaml'
require 'ldblogwriter/parser'
require 'ldblogwriter/command'
require 'ldblogwriter/config'
require 'ldblogwriter/wsse'
require 'ldblogwriter/plugin'

Net::HTTP.version_1_2

module LDBlogWriter
  VERSION = '0.0.1'

  class BlogEntry
    attr_accessor :title, :category, :content
    def initialize(title, category, content)
      @title = title
      @category = category
      @content = content
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

  # ここからスタート
  class Blog
    ConfigFile = ENV['HOME'] + "/.ldblogwriter.conf"

    def initialize()
      @conf = Config.new(ConfigFile)
      check_config
      @plugin = Plugin.new(@conf)
      begin
        @edit_uri_h = YAML.load_file(@conf.edit_uri_file)
      rescue
        @edit_uri_h = Hash.new
      end
    end

    def post_entry(filename, dry_run = true)
      puts "post entry"
      if filename == nil
        print_usage
        exit
      end
      puts "filename : #{filename}"
      # load
      category = ""
      title = ""
      src_text = ""
      File.open(filename, "r") do |file|
        line = file.gets
        line.gsub!(/^<(.*)>\s+/) do |str|
          category = $1
          puts "category : #{category}"
          str.replace("")
        end
        title = line
        puts "title : #{title}"
        src_text = file.read
      end
      if @conf.convert_to_html == true
        content = Parser.new(@conf, @plugin).to_html(src_text)
      else
        content = src_text
      end
      if $DEBUG
        puts category
        puts title
        puts content
      end
      
      command = Command::new
      if @edit_uri_h[File.basename(filename)] == nil
        # post
        if dry_run == false
          edit_uri = command.post(@conf.post_uri, @conf.username,
                                  @conf.password,
                                  title, category, content)
          puts "editURI : #{edit_uri}"
          if edit_uri != false
            save_edit_uri(filename, edit_uri)
          end
        end
      else
        # edit
        if dry_run == false
          edit_uri = @edit_uri_h[File.basename(filename)]
          command.edit(edit_uri, @conf.username, @conf.password,
                       title, category, content)
        end
      end
      # save

    end

    def check_config_api
      # configの内容と、Atom APIでの取得といろいろ
      # まずは一覧から
      if @conf.atom_api_uri != nil
        api_list = Command.new.get(@conf.atom_api_uri, @conf.username, @conf.password)
        if api_list != false
          api_list.doc.elements.each('feed/link') do |element|
            case element.attributes['rel']
            when 'service.post'
              if @conf.post_uri == nil
                @conf.post_uri = element.attributes['href']
              end
            when 'service.feed'
            when 'service.categories'
              @conf.categories_uri = element.attributes['href']
            when 'service.upload'
              if @conf.upload_uri == nil
                @conf.upload_uri = element.attributes['href']
              end
            else
              puts "unknwon service #{element.attributes['rel']}"
            end
          end
        end
      end
      if $DEBUG
        pp @conf
      end
    end

    def check_config_user_and_pass
      if @conf.username == nil
        print "Username: "
        @conf.username = $stdin.gets.chomp
      end
      if @conf.password == nil
        print "Password: "
        @conf.password = $stdin.gets.chomp
      end
    end

    def check_config
      if $DEBUG
        puts "check username and password"
      end
      check_config_user_and_pass
      if $DEBUG
        puts "check Atom APIs"
      end
      check_config_api
    end

    def print_usage
      puts "#{$0} [-n] <text file>" 
    end

    def get_categories
      com = Command.new
      ret = com.get(@conf.categories_uri, @conf.username, @conf.password)
      categories = Array.new
      ret.doc.elements.each('categories/subject') do |category|
        categories.push(category.text)
      end
      return categories
    end


    def save_edit_uri(filename, edit_uri)
      filename = File.basename(filename)
      @edit_uri_h[filename] = edit_uri
      YAML.dump(@edit_uri_h, File.open(@conf.edit_uri_file, 'w'))
    end
  end

end

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'

  class TestBlog < Test::Unit::TestCase
    def test_check_config
      blog = LDBlogWriter::Blog.new('ldblogwriter-lib.rb')
    end
  end
end
