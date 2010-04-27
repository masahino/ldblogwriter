# -*- coding: utf-8 -*-

# ブクログの情報更新
# #booklog(<ASIN>)
# @options['booklog_userid']
# @options['booklog_password']
def booklog(asin)
  require 'date'
  require 'booklog'

  user = @conf.options['booklog_userid']
  pass = @conf.options['booklog_password']
  booklog = Booklog::Agent.new(user, pass)
  booklog.input([asin])
  ""
end

def booklog_post(asin)
  require 'booklog'

  user = @conf.options['booklog_userid']
  pass = @conf.options['booklog_password']
  booklog = Booklog::Agent.new(user, pass)
  
  booklog.comment(asin, @entry.alternate)
  ""
end



