# -*- coding: utf-8 -*-
require 'nokogiri'

module LDBlogWriter

  class AtomResponse
    attr_accessor :source, :doc

    def initialize(source)
      @source = source
      if @source.respond_to?('force_encoding')
        @source.force_encoding('UTF-8')
      end
      @doc = Nokogiri::XML.parse(source)
    end

    # 1つじゃない?
    def uri
      @doc.xpath('//xmlns:link[@rel="alternate"]/@href').to_s
    end

    def collection_uri
      uri_a = []
      @doc.xpath('//xmlns:collection/@href').each do |e|
        uri_a.push(e.value)
      end
      uri_a
    end

    def media_src
      @doc.xpath("//xmlns:content/@src").to_s
    end

    def title
      @doc.xpath("//xmlns:title").text
    end
  end
end
