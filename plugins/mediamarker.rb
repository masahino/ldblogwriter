# -*- coding: utf-8 -*-

# ブクログの情報更新
# #mediamarker(<ASIN>)
# @options['mediamarker_userid']
# @options['mediamarker_password']
def mediamarker(asin)
  require 'date'
  require 'mediamarker'

  user = @conf.options['mediamarker_userid']
  pass = @conf.options['mediamarker_password']
  mediamarker = MediaMarker::Agent.new(user, pass)
  mediamarker.search(asin)
  ""
end

def mediamarker_post(asin)
  require 'mediamarker'

  user = @conf.options['mediamarker_userid']
  pass = @conf.options['mediamarker_password']
  mediamarker = MediaMarker::Agent.new(user, pass)
  
#  booklog.comment(asin, @entry.alternate)
  ""
end



