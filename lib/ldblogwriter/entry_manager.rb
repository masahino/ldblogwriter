# -*- coding: utf-8 -*-
require 'yaml'

module LDBlogWriter
  
  class EntryManager

    def initialize(file_name)
      @yaml_file_name = file_name
      begin
        @edit_uri_h = YAML.load_file(@yaml_file_name)
      rescue
        @edit_uri_h = Hash.new
      end
    end

    def has_entry?(filename)
      if @edit_uri_h[File.basename(filename)] == nil
        false
      else
        true
      end
    end

    def get_edit_uri(filename)
      return @edit_uri_h[File.basename(filename)]
    end

    def save_edit_uri(filename, edit_uri)
      filename = File.basename(filename)
      @edit_uri_h[filename] = edit_uri
      YAML.dump(@edit_uri_h, File.open(@yaml_file_name, 'w'))
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
    
    def get_entries
      @edit_uri_h
    end
  end
end

