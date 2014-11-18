# encoding: utf-8
require "postcontent.rb"
require "mdcontent.rb"
require "colored.rb"
require 'logging'

class ContentAccess
  def config
    @config
  end

  def list
    @all.reverse
  end

  def list_lasts number
    list[0...number]
  end

  def list_by_date
    year = Hash.new
    list.each do |post|
      post_year = post.date.year
      unless year.has_key? post_year
        year[post_year] = Hash.new
      end
      post_month = post.date.month
      unless year[post_year].has_key? post_month
        year[post_year][post_month] = Hash.new
      end
      post_day = post.date.day
      unless year[post_year][post_month].has_key? post_day
        year[post_year][post_month][post_day] = Array.new
      end
      year[post_year][post_month][post_day].push post
    end
    year
  end

  def account? name
    return false unless @config.has_key? "accounts"
    return @config["accounts"].has_key? name
  end

  def account name
    return nil unless account? name
    return @config["accounts"][name]
  end
end

class TagContents < ContentAccess
  def initialize config, elements, tag, tagFile
    @config = config
    @all = elements
    @tag = tag
    @tagFile = tagFile
    @url = "tags/#{@tag}.html"
  end

  def tag
    @tag
  end

  def url
    @url
  end

  def write_to_site
    outFile = File.join "_site", "tags", "#{@tag}.html"
    hamlContent = HamlContent.new @tagFile, self
    hamlContent.url = @url
    html = hamlContent.to_html hamlContent
    File.open(outFile, "w") { |f| f.write html }
  end
end

class Contents < ContentAccess
  include Logging

  def initialize config
    @config = config
    @files = Dir.glob(File.join("_posts", MdContent.glob)).sort
    @pages = Dir.glob(File.join("_pages", MdContent.glob)).sort
    @tagFile = File.join "_layouts", "tags.haml"
    @atomFile = File.join "_pages", "atom.xml.haml"
    @sitemapFile = File.join "_pages", "sitemap.xml.haml"
    @all = Array.new
    @tags = Hash.new
    @urls = Array.new
    @defaultLinks = if File.exists? "links.md" then "\n" + File.open("links.md", "r:utf-8").read else "" end
  end

  def generate all
    generate_posts all
    generate_pages
    generate_tags
    generate_atom
    generate_sitemap
  end

  def urls
    @urls
  end

  def defaultLinks
    @defaultLinks
  end

  private
  def generate_posts all
    logger.info "Posts".blue
    @files.each do |name|
      content = PostContent.new name, self
      str = "  #{name}"
      if content.published || all
        add_tags content
        content.write_to_site
        @all.push content
        @urls.push content.url
      else
        str += "\t\t\t[[skipped]]"
        str = str.pink
      end
      logger.info str
    end
  end

  def generate_pages
    logger.info "Pages".blue
    @pages.each do |name|
      content = MdContent.new name, self
      str = "  #{name}"
      if content.published || all
        content.write_to_site
        @urls.push content.url
      else
        str += "\t\t\t[[skipped]]"
        str = str.pink
      end
      logger.info str
    end
  end

  def generate_tags
    return unless File.exists? @tagFile
    logger.info "Tags".blue
    FileUtils.mkdir_p File.join "_site", "tags"
    @tags.each do |tag, contents|
      logger.info "  #{tag}"
      content = TagContents.new @config, contents, tag, @tagFile
      content.write_to_site
      @urls.push content.url
    end
  end

  def generate_atom
    return unless File.exists? @atomFile
    logger.info "Atom".blue
    hamlContent = HamlContent.new @atomFile, self
    atom = hamlContent.to_html hamlContent
    hamlContent.url = "atom.xml"
    outFile = File.join "_site", "atom.xml"
    File.open(outFile, "w") { |f| f.write atom }
    @urls.push hamlContent.url
  end

  def generate_sitemap
    return unless File.exists? @sitemapFile
    logger.info "Sitemap".blue
    @urls.push "sitemap.xml"
    hamlContent = HamlContent.new @sitemapFile, self
    sitemap = hamlContent.to_html hamlContent
    outFile = File.join "_site", "sitemap.xml"
    File.open(outFile, "w") { |f| f.write sitemap }
  end

  def add_tags content
    content.tags.each do |tag|
      if !@tags.has_key? tag
        @tags[tag] = Array.new
      end
      @tags[tag].push content
    end
  end
end
