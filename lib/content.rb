require 'haml'
require 'digest/md5'

class Content
  def initialize(name, contents)
    @name = name
    @contents = contents
    @plain_content = ""
    @datas = Hash.new
    @date = nil
    @slug = ""
    @ext = ""
    @scope = self
    @locals = {}
    @url = ""

    read
  end

  def link_to absolute_url = "", ext = "html"
    path = absolute_url
    path += ".#{ext}" if absolute_url != "" && File.extname(absolute_url) == ""
    "#{@contents.config["site_url"]}/#{path}"
  end

  def url= url
    @url = url
  end

  def url
    @url
  end

  def contents
    @contents
  end

  def write_to out
    File.open(out, "w") { |f| f.write to_html }
  end

  def name
    @name
  end

  def plain_content
    @plain_content
  end

  def method_missing(m, *args, &block)
    if m =~ /^(.*)\?$/
      return @datas.has_key? $1
    elsif @datas.has_key? m.to_s
      return @datas[m.to_s]
    else
      return nil
    end
  end

  def gravatar?
    email?
  end

  def gravatar
    hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{hash}"
  end

  def published?
    @datas.has_key? 'published'
  end

  def published
    return true unless published?
    @datas['published']
  end

  def date
    @date
  end

  def to_html
  end

  def render opts
    hamlContent = HamlContent.new File.join("_layouts", "_#{opts[:partial]}.haml"), @contents
    hamlContent.to_html self
  end

  protected
  def valid?
    false
  end

  def read
  end
end
