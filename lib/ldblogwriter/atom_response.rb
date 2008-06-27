# -*- coding: utf-8 -*-
require 'rexml/document'

module LDBlogWriter

  class AtomResponse
    attr_accessor :source, :doc

    def initialize(source)
      @source = source
      if @source.respond_to?('force_encoding')
        @source.force_encoding('UTF-8')
      end
      @doc = REXML::Document.new(source)
    end

    # 1つじゃない?
    def uri
      return @doc.elements['entry/link'].attributes['href']
    end

    def title
      return @doc.elements['entry/title'].text
    end
  end
end
