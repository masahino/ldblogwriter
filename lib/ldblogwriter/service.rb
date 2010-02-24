# -*- coding: utf-8 -*-

module LDBlogWriter
  class AbstractService
    def initialize(config)
      @config = config
    end

    def post_entry(content, title, category)
      raise 'Called abstract method: '+caller.first.scan(/`(.*)'/).to_s
    end

    def edit_entry(entry)
      raise 'Called abstract method: '+caller.first.scan(/`(.*)'/).to_s
    end

    def delete_entry(entry)
      raise 'Called abstract method: '+caller.first.scan(/`(.*)'/).to_s
    end

    def post_image(image_file_path)
      raise 'Called abstract method: '+caller.first.scan(/`(.*)'/).to_s
    end

    def to_xml(entry)
      raise 'Called abstract method: '+caller.first.scan(/`(.*)'/).to_s
    end

  end
end

