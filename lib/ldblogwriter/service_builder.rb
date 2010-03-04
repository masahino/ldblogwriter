# -*- coding: utf-8 -*-

require 'ldblogwriter/service.rb'
require 'ldblogwriter/service/livedoor'

module LDBlogWriter
  SERVICE_TYPE_LIVEDOOR = 'livedoor'
  class ServiceBuilder
    def ServiceBuilder::get_service(config)
      case config.service.downcase
      when SERVICE_TYPE_LIVEDOOR
        return Service::LiveDoor::new(config)
      end
    end
  end
end

