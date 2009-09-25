fdef tag(tag_str)
  "<!-- #{tag_str} -->"
end

def tag_post(tag_str)
  case @conf.service
  when 'livedoor'
    require 'rubygems'
    require 'mechanize'
    require 'kconv'
    
    blog_id = @conf.blog_id
    entry_id = @entry.edit_uri.split("=").last
    
    login_uri = "http://member.livedoor.com/login/"
    login_uri = login_uri + "?next=http%3A%2F%2Fcms.blog.livedoor.com%2Fcms%2F&.sv=blog"
    edit_uri = "http://cms.blog.livedoor.com/cms/article/edit?blog_id=#{blog_id}&id=#{entry_id}"

    agent = WWW::Mechanize.new
    page = agent.get(login_uri)
    login_form = page.forms.with.name('loginForm').first

    login_form['livedoor_id'] = @conf.username
    login_form['password'] = @conf.password
    login_form.submit

    page = agent.get(edit_uri)
    edit_form = page.forms.with.name('ArticleForm').first
    puts edit_form
    edit_form['tag'] = tag_str.toeuc
    edit_form.submit(edit_form.buttons.with.name('.save').first)
  else
  end
end

if $0 == __FILE__
  $test = true
end
if defined?($test) && $test
  require 'test/unit'
    require 'rubygems'
    require 'mechanize'
  require 'ldblogwriter'
  require 'pp'
  class TestTag < Test::Unit::TestCase
    def setup
      @config = LDBlogWriter::Config.new(ENV['HOME'] + "/.ldblogwriter.conf")
    end

    def test_tag_post
    login_uri = "http://member.livedoor.com/login/"
#    edit_uri = "http://cms.blog.livedoor.com/cms/article/edit?blog_id=#{blog_id}&id=#{entry_id}"

      agent = WWW::Mechanize.new
      agent.user_agent_alias='Mac FireFox'
      page = agent.get(login_uri)
      pp page
      login_form = page.form('loginForm')
      pp login_form
    end
  end
end
