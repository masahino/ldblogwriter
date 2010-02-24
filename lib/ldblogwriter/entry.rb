# -*- coding: utf-8 -*-

require 'cgi'

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
  end
end
