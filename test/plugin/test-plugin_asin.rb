$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'plugins'

require 'test/unit'
#require 'ldblogwriter/plugin.rb'
require 'ldblogwriter/config.rb'
require 'ldblogwriter/plugin/asin.rb'

class TestPluginAsin < Test::Unit::TestCase
  def setup
    @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    @ecs = AmazonECS.new('access_key_id' => @config.options['amazon_access_key_id'],
                         'secret_key_id' => @config.options['amazon_secret_key_id'])
    end

    def test_get_signature
      request_str = "AWSAccessKeyId=00000000000000000000&ItemId=0679722769&Operation=ItemLookup&ResponseGroup=ItemAttributes%2COffers%2CImages%2CReviews&Service=AWSECommerceService&Timestamp=2009-01-01T12%3A00%3A00Z&Version=2009-01-06"
      ecs = AmazonECS.new({'access_key_id' => "00000000000000000000",
                            'secret_key_id' => "1234567890"})
      assert_equal('Nace%2BU3Az4OhN7tISqgs1vdLBHBEijWcBeCqL5xN9xg%',
                   ecs.get_signature(request_str, 'webservices.amazon.com'))
    end
    
    def test_item_lookup
      assert(@ecs.item_lookup('4101181764'))
  end
  
end
