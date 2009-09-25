# -*- coding: utf-8 -*-

module LDBlogWriter
  class Plugin
    attr_accessor :post_process_list

    def initialize(conf)
      @conf = conf
      @post_process_list = Array.new
      if @conf.plugin_dir != nil
        load_plugins(@conf.plugin_dir)
      end
    end

    def load_plugins(plugin_dir)
      Dir::glob(plugin_dir + "*.rb") do |plugin_file|
        load_plugin(plugin_file)
      end
    end

    def load_plugin(plugin_file)
      begin
        open(plugin_file) do |file|
          instance_eval(file.read)
        end
      rescue
      end
    end

    def eval_src(src)
      if $DEBUG
        puts src
      end
      begin
        eval(src, binding)
      rescue
        puts $!
        "Plugin error"
      end
    end

    def eval_post(entry)
      @entry = entry # FIXME
      @post_process_list.each do |post_process|
        eval_src(post_process)
      end
    end
  end
end

if $0 == __FILE__
#  require 'test-plugin.rb'
  $test = true
end

if defined?($test) && $test
  require 'test/unit'

  class TestPlugin < Test::Unit::TestCase
    def setup
    end

  end
end
