require 'rubygems'
require 'hatena/api/graph'
require 'date'

def hatenagraph(graphname, date, value)
  graph = Hatena::API::Graph.new(@conf.options['hatena_username'],
                                 @conf.options['hatena_password'])
  graph.post_data(graphname, 'date' => Date.parse(date.to_s).to_s,
                  'value' => value)

  return ""
end
