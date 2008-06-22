require 'digest/sha1'
require 'time'

module LDBlogWriter
  class Wsse
    def Wsse::get(user, pass)
      created = Time.now.iso8601
      nonce = Time.now.to_i.to_s + rand().to_s + $$.to_s
      passdigest = Digest::SHA1.digest(nonce + created + pass)
      
      credentials = "UsernameToken Username=\"#{user}\", " +
        "PasswordDigest=\"#{[passdigest].pack('m').chomp}\", " + 
        "Nonce=\"#{[nonce].pack('m').chomp}\", " +
        "Created=\"#{created}\""
      
      return credentials
    end
  end

end
