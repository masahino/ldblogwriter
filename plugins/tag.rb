def tag(tag_str)
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
