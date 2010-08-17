$LOAD_PATH.unshift 'lib'

require 'test/unit'
require 'webrick'

require 'ldblogwriter/service/blogger.rb'
require 'ldblogwriter/config.rb'


class TestLiveDoor < Test::Unit::TestCase
  def setup
    config_file = "test/test.conf"
    conf = LDBlogWriter::Config.new(config_file)
    @ld = LDBlogWriter::Service::Blogger::new(conf)
  end
  
  def test_to_xml
    assert(@ld.to_xml("test content", "test title", "test"))
  end

  def test_post_entry
    with_http {|srv, dr, url|
      ret = @ld.post_entry("test content", "this is test", "test")
    }
    assert_instance_of(String, ret)
  end

  def with_http
    Dir.mktmpdir {|dr|
    srv = WEBrick::HTTPServer.new({
                                    :ServerType => Thread,
#        :Logger => WEBrick::Log.new(NullLog),
#        :AccessLog => [[NullLog, ""]],
        :BindAddress => '127.0.0.1',
        :Port => 8000})
      _, port, _, host = srv.listeners[0].addr
    begin
      th = srv.start
      yield srv, dr, "http://#{host}:#{port}"
    ensure
      srv.shutdown
    end
    }
  end
end

