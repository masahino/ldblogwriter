require 'test/unit'
require '../lib/ldblogwriter/config'
require 'asin.rb'


class TestAmazonECS < Test::Unit::TestCase
  def setup
    @config = LDBlogWriter::Config.new(ENV['HOME']+'/.ldblogwriter.conf')
    @ecs = AmazonECS.new('subscription_id' => @config.options['amazon_sub_id'],
                         'associate_tag' => @config.options['amazon_assoc_id'])
  end

  def test_item_lookup
    assert(@ecs.item_lookup('4101181764'))
  end
end
