# -*- coding: utf-8 -*-
require 'open-uri'
require 'pp'
require 'ldblogwriter/entry_manager.rb'
require 'yaml'

# parserは、pukiwikiparser.rbを参考にしています。
# http://jp.rubyist.net/magazine/?0010-CodeReview

# pluginの形式は
# #プラグイン名
# #プラグイン名(arg1, arg2...)

module LDBlogWriter

  attr_accessor :entry

  class Parser
    def initialize(conf, plugin, service = nil)
      @conf = conf
      @plugin = plugin
      @service = service
    end

    def get_entry(src_text)
      lines = src_text.rstrip.split(/\r?\n/)
      first_line = lines.shift
      category = nil
      first_line.gsub!(/^<(.*)>\s+/) do |str|
        category = $1
        str.replace("")
      end
      title = first_line
      src_text = lines.join("\n")
      @entry = BlogEntry.new(title, category)
      if @conf.convert_to_html == true
#        src_text = check_image_file(filename, src_text)
        content = to_html(src_text)
#        if @conf.html_directory != nil
#          save_html_file(@conf.html_directory, File.basename(filename), content)
#        end
      else
        content = src_text
      end
      @entry.content = content
      return @entry
    end

    def escape_html(str)
      str.gsub!(/&/, '&amp;')
      str.gsub!(/"/, '&quot;')
      str.gsub!(/</, '&lt;')
      str.gsub!(/>/, '&gt;')
      return str
    end

    def to_html(src, entry = nil)
      if entry != nil
        @entry = entry
      end
      buf = []
      lines = src.rstrip.split(/\r?\n/).map {|line| line.chomp}

      while lines.first
        case lines.first
        when ''
          lines.shift
        when /\A----/
          lines.shift
          buf.push '<hr />'
        when /\A#trackback\(.*\)/
          buf.push parse_trackback(lines.shift)
        when /\A#img\(.*\)/
          buf.push parse_img(lines.shift)
        when /\A\s/
          buf.concat parse_pre(take_block(lines, /\A\s/))
        when /\A>/
          buf.concat parse_quote(take_block(lines, /\A>/))
        when /\A-/
          buf.concat parse_list('ul', take_block(lines, /\A-/))
        when /\A\+/
          buf.concat parse_list('ol', take_block(lines, /\A\+/))
        when /\A#.*/
            buf.push parse_plugin(lines.shift)
        else
          buf.push '<p>'
          buf.concat parse_p(take_block(lines, /\A(?![*\s>:\-\+]|----|\z)/))
          buf.push '</p>'
        end
      end
      buf.join("\n")
    end

#private

    def take_block(lines, marker)
      buf = []
      until lines.empty?
        break unless marker =~ lines.first
        buf.push lines.shift.sub(marker, '')
      end
      buf
    end

    def syntax_highlight(lines, lang)
      require 'syntax/convertors/html'
      convertor = Syntax::Convertors::HTML.for_syntax lang
      ["<div class=\"ruby\">" + convertor.convert(lines.join("\n")) + "</div>\n"]
    end

    def parse_pre(lines)
      # コードのハイライト対応
      if lines.first =~ /\Ahighlight\((.*)\)/
        lines.shift
        syntax_highlight(lines, $1)
      else
        ["<pre>#{lines.map {|line| escape_html(line) }.join("\n")}",
        '</pre>']
      end
    end

    def parse_quote(lines)
       [ "<blockquote><p>", lines.join("\n"), "</p></blockquote>"]
    end

    def parse_list(type, lines)
      marker = ((type == 'ul') ? /\A-/ : /\A\+/)
      parse_list0(type, lines, marker)
    end

    def parse_list0(type, lines, marker)
      buf = ["<#{type}>"]
      closeli = nil
      until lines.empty?
        if marker =~ lines.first
          buf.concat parse_list0(type, take_block(lines, marker), marker)
        else
          buf.push closeli if closeli;  closeli = '</li>'
          buf.push "<li>#{parse_inline(lines.shift)}"
        end
      end
      buf.push closeli if closeli;  closeli = '</li>'
      buf.push "</#{type}>"
      buf
    end
    
    def parse_plugin(line)
      eval_string = line.gsub(/\A#/, "")
      # regist post process action
      post_method_name = eval_string[/\A\w+/]+"_post"
      if @plugin.respond_to?(post_method_name)
        @plugin.post_process_list.push(eval_string.gsub(/\A(\w+)/) { $1+"_post" })
      end
      
      @plugin.eval_src(eval_string)
    end

    def get_small_img_uri(img_uri)
      if $DEBUG
        puts img_uri
      end
      uri = URI.parse(img_uri)
      new_path = uri.path.gsub(/\.(\w+)$/, '-s.\1')
      uri.path = new_path
      return uri.to_s
    end

    def get_img_html(img_uri, title)
      result = ""
      small_img_uri = get_small_img_uri(img_uri)
      result += "<a href=\"#{img_uri}\" target=\"_blank\">"
      result += "<img src=\"#{small_img_uri}\" alt=\"#{title}\" "
      result += "hspace=\"5\" class=\"pict\" align=\"left\" />"
      result += "</a>"
      return result
    end

    def parse_trackback(line)
      buf = []
      line.scan(/\#trackback\((.*)\).*/) do |url|
        @entry.trackback_url_array += url
      end
      return buf
    end

    # TODO: plugin化
    def parse_img(line)
      buf = []
      img_str = ""
      if line =~ /\A#img\((.*)\).*/
        img_str = $1
        img_str.gsub!(/\s+/, "")
      end
      (img_path, img_title) = img_str.split(",")
      if img_title == nil
        img_title = File.basename(img_path)
      end
      img_manager = LDBlogWriter::EntryManager.new(@conf.upload_uri_file)
      if img_manager.has_entry?(File.basename(img_path)) == false
        # 新規アップロード
        img_uri = @service.post_image(img_path, img_title)
        if img_uri == false
          return buf
        end
        img_manager.save_edit_uri(File.basename(img_path), img_uri)
      else
        img_uri = img_manager.get_edit_uri(File.basename(img_path))
      end
      buf.push(get_img_html(img_uri, img_title))
      # アップロードデータ保存
      return buf
    end

    def parse_p(lines)
      lines.map {|line| parse_inline(line) }
    end

    def a_href(uri, label, cssclass)
      if @conf.auto_trackback == true
        open(uri) do |f|
          if f.content_type != "text/html"
            break
          end
          contents = f.read
          trackback_ping = []
          contents.scan(%r|<rdf:Description\s+([^>]+)>|) do |attr|
            attr[0].scan(%r|\s+([^=]+)="([^\"]+)"|) do |key, value|
              trackback_ping << value if key == 'trackback:ping'
            end
          end
          if @entry != nil
            @entry.trackback_url_array += trackback_ping
          end
        end
      end
      %Q[<a class="#{cssclass}" href="#{escape_html(uri)}">#{escape_html(label)}</a>]
    end

    def parse_inline(str)
      @inline_re ||= %r<
        ([&<>"])                             # $1: HTML escape characters
      | \[\[(.+?):\s*(https?://\S+)\s*\]\]   # $2: label, $3: URI
      | (#{URI.regexp('http')})              # $5...: URI autolink
      >x
      str.gsub(@inline_re) {
        case
        when htmlchar = $1 then escape_html(htmlchar)
        when bracket  = $2 then a_href($3, bracket, 'outlink')
#        when pagename = $4 then "not support $3" #a_href(page_uri(pagename), pagename, 'pagelink')
        when uri      = $4 then a_href(uri, uri, 'outlink')
        else
          raise 'must not happen'
        end
      }
    end
  end

end

