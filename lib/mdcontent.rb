# encoding: utf-8
require "hamlcontent.rb"
require 'redcarpet'
require 'pygments'
require 'html_truncator'

# create a custom renderer that allows highlighting of code blocks
class HTMLwithPygments < Redcarpet::Render::XHTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language)
  end
end

class MdContent < Content
  @@glob = "*.{md,mkd,markdown}"

  def self.glob
    @@glob
  end

  MATCHER = /^(.+\/)*(\d+-\d+-\d+)?-?(.*)(\.[^.]+)$/

  def write_to_site
    out = File.join "_site", url
    FileUtils.mkdir_p File.dirname out
    write_to out
  end

  def content
    markdown = Redcarpet::Markdown.new(HTMLwithPygments, :with_toc_data => true, :fenced_code_blocks => true, :strikethrough => true, :autolink => true, :no_intra_emphasis => true, :tables => true)
    src = @plain_content
    if useDefaultLinks?
      src += @contents.defaultLinks
    end
    markdown.render src
  end

  def excerpt striphtml = false, length = 30, ellipsis = "…"
    truncate = HTML_Truncator.truncate content, length, :ellipsis => ellipsis
    if striphtml
      truncate.gsub!(/<[^>]+>/, '')
    else
      truncate.gsub!(/<\/?img[^>]*>/, '')
    end
    return truncate
  end

  def to_html
    if layout?
      hamlContent = HamlContent.new File.join("_layouts", "#{layout}.haml"), @contents
      return hamlContent.to_html self
    end
    content
  end

  def url
    "#{CGI.escape @slug}.html"
  end

  protected

  def read
    raise "File #{@name} doesn't exists" if !File.exists? @name

    raise "File #{@name} is not a valid file name" unless valid?

    @plain_content = File.open(@name, "r:utf-8").read
    begin
      if @plain_content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @plain_content = $'
        @datas = YAML.load $1
      end
    rescue => e
      puts "YAML Exception reading #{@name}: #{e.message}"
    end

    m, cats, date, slug, ext = *name.match(MATCHER)
    @date = Time.parse(date) if date
    @slug = slug
    @ext = ext
  end

  def valid?
    @name =~ MATCHER
  end

  def useDefaultLinks?
    if @datas.has_key? 'nolinks'
      @datas['nolinks'] == 'true'
    else
      true
    end
  end

end
