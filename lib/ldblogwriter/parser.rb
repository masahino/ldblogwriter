require 'open-uri'
require 'pp'
require 'ldblogwriter/command'
require 'yaml'

# parserは、pukiwikiparser.rbを参考にしています。
# http://jp.rubyist.net/magazine/?0010-CodeReview

# pluginの形式は
# #プラグイン名
# #プラグイン名(arg1, arg2...)

module LDBlogWriter

  class Parser
    def initialize(conf, plugin)
      @conf = conf
      @plugin = plugin
    end

    def escape_html(str)
      str.gsub!(/&/, '&amp;')
      str.gsub!(/"/, '&quot;')
      str.gsub!(/</, '&lt;')
      str.gsub!(/>/, '&gt;')
      return str
    end

    def to_html(src, entry = nil)
      @entry = entry
      buf = []
      lines = src.rstrip.split(/\r?\n/).map {|line| line.chomp}

      while lines.first
        case lines.first
        when ''
          lines.shift
        when /\A----/
          lines.shift
          buf.push '<hr />'
        when /\A!trackback\(.*\)/
          buf.push parse_trackback(lines.shift)
        when /\Aimg\(.*\)/
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
      @plugin.eval_src(line.gsub(/\A#/, ""))
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
      line.scan(/\!trackback\((.*)\).*/) do |url|
        @entry.trackback_url_array += url
      end
      return buf
    end

    # TODO: plugin化
    def parse_img(line)
      buf = []
      img_str = ""
      if line =~ /\Aimg\((.*)\).*/
        img_str = $1
        img_str.gsub!(/\s+/, "")
      end
      (img_path, img_title) = img_str.split(",")
      if img_title == nil
        img_title = File.basename(img_path)
      end
      if File.exist?(img_path)
        # 既にupload済かどうかチェック
        begin
          upload_uri_h = YAML.load_file(@conf.upload_uri_file)
        rescue
          upload_uri_h = Hash.new
        end

        if upload_uri_h[File.basename(img_path)] == nil
          # 新規アップロード
          com = Command.new
          img_uri = com.upload(@conf.upload_uri, @conf.username, @conf.password,
                               img_path, img_title)
          if img_uri != false
            upload_uri_h[File.basename(img_path)] = img_uri
            if @conf.upload_uri_file != nil and 
                File.exist?(@conf.upload_uri_file)
              YAML.dump(upload_uri_h, File.open(@conf.upload_uri_file, 'w'))
            end
          else
            #error
            exit
          end
        else
          img_uri = upload_uri_h[File.basename(img_path)]
        end
        buf.push(get_img_html(img_uri, img_title))
        # アップロードデータ保存
        
      end
      return buf
    end

    def parse_p(lines)
      lines.map {|line| parse_inline(line) }
    end

    def a_href(uri, label, cssclass)
      if @conf.auto_trackback == true
        open(uri) do |f|
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

if $0 == __FILE__
  require 'test-parser.rb'
  $test = true
end

if defined?($test) && $test
  require 'test/unit'

  class TestParser < Test::Unit::TestCase
    def setup
      @parser = LivedoorBlogWriter::Parser.new(BlogWriter::Config.new('test.conf'))
    end

  end
end
