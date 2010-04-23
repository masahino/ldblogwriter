# -*- coding: utf-8 -*-

require 'cgi'

module LDBlogWriter
  class BlogEntry
    attr_accessor :title, :category, :content
    attr_accessor :alternate_uri
    attr_accessor :send_tb
    attr_accessor :trackback_url_array
    attr_accessor :edit_uri
    attr_accessor :updated_time, :published_time
    attr_accessor :id
    
    def initialize(title, category = nil, content = "")
      @title = title
      @category = category
      @content = content
      @send_tb = false
      @trackback_url_array = []
    end

  end
end
