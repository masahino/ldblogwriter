# -*- coding: utf-8 -*-
require 'uri'
require 'net/http'
require 'cgi'

require 'ldblogwriter/service/atompub.rb'
require 'ldblogwriter/service.rb'

module LDBlogWriter
  module Service
    class Blogger < AtomPubClient
      GOOGLE_LOGIN_URL = 'https://www.google.com/accounts/ClientLogin'

      def initialize(config)
        super(config.username, config.password, config.auth_type)
        @entry_uri = config.post_uri
      end

      def authenticate(username, password, authtype)
        return {'Authorization' => 'GoogleLogin auth='+
          get_google_auth_token(username, password)}
      end

      def to_xml(content, title, category = nil)
        data = "<entry xmlns='http://www.w3.org/2005/Atom'>\n"
        data += "<title type='text'>#{title}</title>\n"
        data += "<content type='xhtml'>\n"
        data += "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n"
        data += content
        data += "</div>\n"
        data += "</content>\n"
        data += "<author>\n"
        #      data += "<name>#{@conf.username}</name>\n"
        #      data += "<email>#{@conf.username}</email>\n"
        data += "</author>\n"
        data += "</entry>\n"
        return data
      end

      def get_google_auth_token(username, password)
        url = URI.parse(GOOGLE_LOGIN_URL)
        req = Net::HTTP::Post.new(url.path)
        
        req.form_data = {'Email' => username,
          'Passwd' => password,
          'service' => 'blogger', 
          'accountType' => 'GOOGLE',
          'source' => "lbw-1"}
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        store = OpenSSL::X509::Store.new
        store.set_default_paths
        https.cert_store = store
        https.start do
          res = https.request(req)
          if res.body =~ /Auth=(.+)/
            return $1
          else
            puts res.body
          end
        end
        return nil
      end

    end
  end
end


