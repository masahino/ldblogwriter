module LDBlogWriter
  class Config
    attr_accessor :atom_api_uri, :categories_uri
    attr_accessor :post_uri, :upload_uri, :username, :password
    attr_accessor :edit_uri_file, :upload_uri_file
    attr_accessor :convert_to_html, :html_directory
    attr_accessor :plugin_dir
    attr_accessor :options
    attr_accessor :dry_run
    attr_accessor :blog_title
    attr_accessor :blog_id
    attr_accessor :auto_trackback
    attr_accessor :service
    attr_accessor :auth_type

    def initialize(filename = nil)
      @options = Hash.new
      @auto_trackback = false
      @blog_title = ""
      @service = 'livedoor'
      @auth_type = 'wsse'
      if filename != nil
        puts filename
        load(filename)
      end
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
