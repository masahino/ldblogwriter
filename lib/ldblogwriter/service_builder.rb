# -*- coding: utf-8 -*-

require 'ldblogwriter/service.rb'
require 'ldblogwriter/services/livedoor'

module LDBlogWriter
  SERVICE_TYPE_LIVEDOOR = 'livedoor'
  class ServiceBuilder
    def ServiceBuilder::get_service(config)
      case config.service.downcase
      when SERVICE_TYPE_LIVEDOOR
        return LiveDoor::new(config)
      end
    end
  end
end


if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'
  
  require 'config'

  class SericeBuilderLiveDoor < Test::Unit::TestCase
    def setup
      config_file = ENV['HOME'] + "/.ldblogwriter.conf"
      @conf = LDBlogWriter::Config.new(config_file)
    end

    def test_get_service
      LDBlogWriter::ServiceBuilder::get_service(@conf)
    end
  end
end

