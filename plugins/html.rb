# -*- coding: utf-8 -*-
require 'pp'
 
# HTMLをそのまま
def html(str)
  str
end

if $0 == __FILE__
  $test = true
end

if defined?($test) && $test
  require 'test/unit'

    def test_html

    end
end
