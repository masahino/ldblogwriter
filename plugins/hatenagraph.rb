require 'rubygems'
require 'hatena/api/graph'

def hatenagraph(graphname, date, value)
  graph = Hatena::API::Graph.new(@conf.options['hatena_username'],
                                 @conf.options['hatena_password'])
  graph.post_data(graphname, 'date' => date, 'value' => value)

  return ""
end
