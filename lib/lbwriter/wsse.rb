require 'digest/sha1'
require 'base64'
require 'time'

module LivedoorBlogWriter
  class Wsse
    def Wsse::get(user, pass)
      created = Time.now.iso8601
      nonce = Time.now.to_i.to_s + rand().to_s + $$.to_s
      passdigest = Digest::SHA1.digest(nonce + created + pass)
      
      credentials = "UsernameToken Username=\"#{user}\", " +
        "PasswordDigest=\"#{Base64.encode64(passdigest).chomp}\", " + 
        "Nonce=\"#{Base64.encode64(nonce).chomp}\", " +
        "Created=\"#{created}\""
      
      return credentials
    end
  end

end
