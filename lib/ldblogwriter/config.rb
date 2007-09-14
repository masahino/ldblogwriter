module LDBlogWriter
  class Config
    attr_accessor :atom_api_uri, :categories_uri
    attr_accessor :post_uri, :upload_uri, :username, :password
    attr_accessor :edit_uri_file, :upload_uri_file
    attr_accessor :convert_to_html
    attr_accessor :plugin_dir
    attr_accessor :options

    def initialize(filename)
      @options = Hash.new
      load(filename)
    end

    def load(filename)
      File.open(filename) do |f|
        while line = f.gets
          eval(line) #, binding)
        end
      end
    end
  end
end
