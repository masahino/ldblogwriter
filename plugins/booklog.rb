# -*- coding: utf-8 -*-

# ブクログの情報更新
# #booklog(<ASIN>)
# @options['booklog_userid']
# @options['booklog_password']
def booklog(asin)
  require 'date'
  require 'webookshelf/booklog'

  user = @conf.options['booklog_userid']
  pass = @conf.options['booklog_password']
  booklog = Booklog::Agent.new(user, pass)
  booklog.input([asin])
  ""
end

def booklog_post(asin)
  require 'webookshelf/booklog'

  user = @conf.options['booklog_userid']
  pass = @conf.options['booklog_password']
  booklog = Booklog::Agent.new(user, pass)
  
  booklog.comment(asin, @entry.alternate_uri)
  ""
end

# state: 'read', ...
# rank: 1,2,3,...
def booklog_post(asin, state, rank)
  require 'webookshelf/booklog'

  user = @conf.options['booklog_userid']
  pass = @conf.options['booklog_password']
  booklog = Booklog::Agent.new(user, pass)
  
  booklog_status = nil
  case state
  when 'read'
    booklog_status = "3"
  else
    booklog_status = nil
  end
  booklog.edit(asin, {'rank' => rank.to_s, 
                 'status' => booklog_status,
                 'description' => @entry.alternate_uri})
  ""
end



