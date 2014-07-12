# encoding: utf-8
require "content.rb"
require 'html_truncator'
require 'time'

class GallerieContent < Content
  def initialize(name, contents)
    super(name, contents)
    @pictures = Array.new
    @thumbs = Array.new
    
    copy_pictures
    copy_thumbs
  end
  
  MATCHER = /^(.+\/)*(\d+-\d+-\d+)?-?(.*)$/

  def copy_pictures
    out = File.join "_site", url
    Dir.glob(File.join(name, "*.JPG")).sort.each do |picture_name|
      picture_dir = File.dirname(out)+"/"+CGI.escape(@slug)
      FileUtils.mkdir_p picture_dir
      FileUtils.cp_r picture_name, picture_dir
      @pictures.push "#{@contents.config["site_url"]}/"+File.dirname(url)+"/"+CGI.escape(@slug)+"/"+File.basename(picture_name)
    end
  end
  
  def copy_thumbs
    out = File.join "_site", url
    Dir.glob(File.join(name, "thumbs", "*.JPG")).sort.each do |thumbs_name|
      thumbs_dir = File.dirname(out)+"/"+CGI.escape(@slug)+"/thumbs"
      FileUtils.mkdir_p thumbs_dir
      FileUtils.cp_r thumbs_name, thumbs_dir
      @thumbs.push "#{@contents.config["site_url"]}/"+File.dirname(url)+"/"+CGI.escape(@slug)+"/thumbs/"+File.basename(thumbs_name)
    end
  end

  def write_to_site
    out = File.join "_site", url
    FileUtils.mkdir_p File.dirname out
    write_to out
  end
  
  def url
    {
      "year"  => @date.strftime("%Y"),
      "month" => @date.strftime("%m"),
      "day"   => @date.strftime("%d"),
      "title" => CGI.escape(@slug)
    }.inject("galeries/:year/:month/:day/:title.html") { |result, token|
      result.gsub(/:#{Regexp.escape token.first}/, token.last)
    }.gsub(/\/\//, "/")
  end
  
  def full_title
    "#{formated_date} : #{title}"
  end

  def formated_date
    @date.strftime("%d/%m/%Y")
  end
  
  def to_html
    if layout?
      hamlContent = HamlContent.new File.join("_layouts", "#{layout}.haml"), @contents
      return hamlContent.to_html self
    end
    content
  end
  
  def content
    markdown = Redcarpet::Markdown.new(HTMLwithPygments, :with_toc_data => true, :fenced_code_blocks => true, :strikethrough => true, :autolink => true, :no_intra_emphasis => true, :tables => true)
    src = @plain_content
    if useDefaultLinks?
      src += @contents.defaultLinks
    end
    markdown.render src
  end
  
  def pictures
    @pictures
  end
  
  def excerpt striphtml = false, length = 30, ellipsis = "…"
    picture_descr=""
    i=0
    @thumbs.each do |pic|
      i+=1
      if i<5 then
        picture_descr+="<img src='"+pic+"' alt='"+pic+"' />"
      end
    end
    return picture_descr
  end
  
  protected

  def read
    @index_name= @name+"/index.md"
    raise "File #{@index_name} doesn't exists" if !File.exists? @index_name

    raise "File #{@index_name} is not a valid file name" unless valid?

    @plain_content = File.open(@index_name, "r:utf-8").read
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
