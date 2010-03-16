$LOAD_PATH.unshift 'lib'

require 'test/unit'

require 'test/service/test-livedoor.rb'
require 'test/service/test-blogger.rb'
require 'test/service/test-hatena.rb'

class TestService < Test::Unit::TestCase
end
