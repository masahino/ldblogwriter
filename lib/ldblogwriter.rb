# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"

require 'net/http'
require 'rexml/document'
require 'pp'
require 'uri'
require 'yaml'
require 'kconv'

require 'ldblogwriter/parser'
require 'ldblogwriter/command'
require 'ldblogwriter/config'
require 'ldblogwriter/wsse'
require 'ldblogwriter/plugin'
require 'ldblogwriter/trackback'
require 'ldblogwriter/entry'
require 'ldblogwriter/service_builder.rb'

Net::HTTP.version_1_2

module LDBlogWriter
  VERSION = '0.4.1'

  GOOGLE_LOGIN_URL = 'https://www.google.com/accounts/ClientLogin'

  # ここからスタート
  class Blog
    ConfigFile = ENV['HOME'] + "/.ldblogwriter.conf"

    def initialize(config_file = nil)
      if config_file == nil
        @conf = Config.new(ConfigFile)
      else
        @conf = Config.new(config_file)
      end
      @service = ServiceBuilder::get_service(@conf)
      check_config
      if $DEBUG
        puts "blog title:" + @conf.blog_title
      end
      @plugin = Plugin.new(@conf)
      begin
        @edit_uri_h = YAML.load_file(@conf.edit_uri_file)
      rescue
        @edit_uri_h = Hash.new
      end
    end

    def post_entry(filename, dry_run = true)
      @blog_filename = filename
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
      content = ""
      File.open(filename, "r") do |file|
        line = file.gets
        line = Kconv::toutf8(line)
        line.gsub!(/^<(.*)>\s+/) do |str|
          category = $1
          if get_categories.include?(category)
            puts "category : #{category}"
          else
            puts "unknown category : #{category}"
          end
          str.replace("")
        end
        title = line
        puts "title : #{title}"
        src_text = file.read
        src_text = Kconv::toutf8(src_text)
      end
      entry = BlogEntry.new(@conf, title, category)
      if @conf.convert_to_html == true
        src_text = check_image_file(filename, src_text)
        content = Parser.new(@conf, @plugin, @service).to_html(src_text, entry)
        if @conf.html_directory != nil
          save_html_file(@conf.html_directory, File.basename(filename), content)
        end
      else
        content = src_text
      end
      entry.content = content
      if $DEBUG
        puts "category: " + entry.category
        puts "title: " +entry.title
        puts "contnt: " + entry.content
      end
      
      command = Command::new(@conf.auth_type)
      if @edit_uri_h[File.basename(filename)] == nil
        # post
        if dry_run == false
#          edit_uri = command.post(@conf.post_uri, @conf.username,
#                                  @conf.password,
#                                  entry)
          edit_uri = @service.post_entry(entry.content, entry.title, entry.category)
          if $DEBUG
            puts "editURI : #{edit_uri}"
          end
          if edit_uri != false
            save_edit_uri(filename, edit_uri)
            entry.get_entry_info(edit_uri)
          end
        end
      else
        # edit
        if dry_run == false
          edit_uri = @edit_uri_h[File.basename(filename)]
          command.edit(edit_uri, @conf.username, @conf.password,
                       entry)
          entry.get_entry_info(edit_uri)
        end
      end
      # save
      if @conf.auto_trackback == true
        entry.trackback_url_array.uniq!
        entry.trackback_url_array.each do |trackback_url|
          print "Send trackback to #{trackback_url} ? (y/n) "
          ret = $stdin.gets.chomp
          pp ret
          if ret == "y" or ret == "Y" 
            TrackBack.send(trackback_url, @conf.blog_title, entry.title,
                           entry.summary, entry.alternate)
          end
        end
      end

      # post process
      @plugin.eval_post(entry)
    end

    # ファイル名と同じ名前で拡張子が、"jpg"のファイルがあったら
    # アップロードしてエントリーの先頭に入れる。
    def check_image_file(filename, src_text)
      ext_list = ['.jpg', '.png']
      ext_list.each do |ext|
        img_filename = File::basename(filename, ".txt") + ext
        img_filename = File::dirname(filename) + "/" + img_filename
        if $DEBUG
          puts img_filename
        end
        if File::exist?(img_filename) == true
          src_text = "img(#{img_filename})\n\n" + src_text
          break
        end
      end
      if $DEBUG
        puts src_text
      end
      return src_text
    end

    def check_blog_info
      if @conf.atom_api_uri != nil
        blog_info = Command.new.get(@conf.atom_api_uri + "/blog_id=" + @conf.blog_id,
                                    @conf.username, @conf.password)
        if blog_info != false
          blog_info.doc.elements.each('feed/title') do |element|
            @conf.blog_title = element.text
          end
        end
      end
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
                puts "!!!!!set  post uri"
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
#      check_blog_info
if $DEBUG
  pp @conf
end
    end

    def print_usage
      puts "#{$0} [-n] <text file>" 
    end

    def get_services
      com = Command.new
      service_list = Command.new.get(@conf.atom_api_uri, @conf.username, @conf.password)
#      if service_list != false
#        service_list.doc.elements.each('feed/link') do |element|
#          puts element.attributes['rel'] + ":" + element.attributes['href']
#        end
#      end
      return service_list
    end

    def get_categories
      categories = Array.new
      com = Command.new
      if @conf.categories_uri != nil
        ret = com.get(@conf.categories_uri, @conf.username, @conf.password)
        ret.doc.elements.each('categories/subject') do |category|
          categories.push(category.text)
        end
      end
      return categories
    end

    def save_edit_uri(filename, edit_uri)
      filename = File.basename(filename)
      @edit_uri_h[filename] = edit_uri
      if @conf.edit_uri_file != nil
        YAML.dump(@edit_uri_h, File.open(@conf.edit_uri_file, 'w'))
      end
    end

    def save_html_file(directory, filename, text)
      # directoryなかったら作る
      if File.exists?(directory) 
        if File.ftype(directory) != "directory"
          puts "#{directory} is not directory"
          return
        end
      else
        Dir.mkdir(directory)
      end
      # open
      html_filename = filename.gsub(/.txt$/, ".html")
      if $DEBUG
        puts "write html to #{html_filename}"
      end
      File.open(directory + "/" + html_filename, "w") do |file|
        file.write(text)
      end
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
      blog = LDBlogWriter::Blog.new()
    end
  end
end
