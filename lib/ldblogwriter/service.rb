# -*- coding: utf-8 -*-

module LDBlogWriter
  class AbstractService
    def initialize(config)
      @config = config
    end

    def post_entry(content, title, category)
      
    end

    def edit_entry(entry)
    end

    def delete_entry(entry)
    end

    def post_image(image_file_path)
    end

    def to_xml(entry)
    end

  end
end

