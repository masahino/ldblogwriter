$LOAD_PATH << '../../lib' unless $LOAD_PATH.include? '..'

require 'net/http'
require 'net/https'
require 'uri'
require 'ldblogwriter-lib'
require 'ldblogwriter/wsse'
require 'ldblogwriter/atom_response'

module LDBlogWriter

  class Command
    attr_accessor :auth_type

    def initialize(auth_type = 'wsse')
      @auth_type = auth_type
    end

    def get_google_auth_token(username, password)
      url = URI.parse(LDBlogWriter::GOOGLE_LOGIN_URL)
      req = Net::HTTP::Post.new(url.path)
      req.form_data = {'Email' => username,
        'Passwd' => password,
        'service' => 'blogger', 'source' => "lbw-#{VERSION}"}

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      https.cert_store = store
      https.start {
        res = https.request(req)
        if res.body =~ /Auth=(.+)/
          return $1
        end
      }
      return nil
    end

    def get_auth_info(username, password)
      case @auth_type
      when 'wsse'
        return {'X-WSSE' => Wsse::get(username, password)}
      when 'google'
        return {'Authentication' => get_google_auth_token(username, password)}
      else
        raise ArgumentError, "unknwon auth type: #{@auth_type}"
      end
    end

    def get(uri_str, username, password)
      uri = URI.parse(uri_str)
      pp uri.path
      Net::HTTP.start(uri.host, uri.port) do |http|
        res = http.get(uri.path,
                       get_auth_info(username, password))
        if res.code != "200"
          puts res.body
          return false
        end
        return AtomResponse.new(res.body)
      end
    end

    def upload(uri_str, username, password, filename, title = nil)
      if title == nil
        title = File.basename(filename)
      end
      entry = UploadEntry.new(title, filename)
      uri = URI.parse(uri_str)
      data = entry.to_xml
      if $DEBUG
        puts data
      end
      Net::HTTP.start(uri.host, uri.port) do |http|
        res = http.post(uri.path, data,
                       get_auth_info(username, password))
        if $DEBUG
          puts res
        end
        if res.code != "201"
          puts res.body
          return false
        end
        img_uri = AtomResponse.new(res.body).uri
        return img_uri
      end
    end

    def post(uri_str, username, password, entry)
      uri = URI.parse(uri_str)
      Net::HTTP.start(uri.host, uri.port) do |http|
#        entry = BlogEntry.new(entry.title, entry.category, entry.content)
        data = entry.to_xml
        res = http.post(uri.path, data,
                       get_auth_info(username, password))
        case res.code
        when "201"
          edit_uri = res['Location']
        when "404"
          puts res.body
          edit_uri = false
        when "200"
          puts res.body
          edit_uri = false
        else
          edit_uri = false
        end

        return edit_uri
      end
    end

    def edit(uri_str, user, pass, entry)
      uri = URI.parse(uri_str)
      Net::HTTP.start(uri.host, uri.port) do |http|
#        entry = BlogEntry.new(entry.title, entry.category, entry.content)
        data = entry.to_xml
        res = http.put(uri.path, data, get_auth_info(username, password))
        if $DEBUG
          puts res
        end
        if res.code != "200"
          return false
        end
        return true
      end
    end

    # delete blog entry
    def delete(uri_str, user, pass)
      uri = URI.parse(uri_str)
      Net::HTTP.start(uri.host, uri.port) do |http|
        res = http.delete(uri.path, 
                          get_auth_info(username, password))

        if $DEBUG
          puts res
        end
        case res.code
        when "200"
          return true
        when "400"
          # blog_idが存在しない、あるいはBlogに投稿する権限がない
          return false
        when "403"
          # 権限なし
          return false
        end
      end
    end

  end
end
