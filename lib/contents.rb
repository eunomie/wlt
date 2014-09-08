# encoding: utf-8
require "postcontent.rb"
require "galleriescontent.rb"
require "mdcontent.rb"

class ContentAccess
  def config
    @config
  end

  def list_posts
    @posts.reverse
  end

  def list_lasts_posts number
    list_posts[0...number]
  end

  def list_posts_by_date
    year = Hash.new
    list_posts.each do |post|
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
  
  def list_galleries
    @galleries.reverse
  end

  def list_lasts_galleries number
    list_galleries[0...number]
  end

  def list_galleries_by_date
    year = Hash.new
    list_galleries.each do |gallery|
      gallery_year = gallery.date.year
      unless year.has_key? gallery_year
        year[gallery_year] = Hash.new
      end
      gallery_month = gallery.date.month
      unless year[gallery_year].has_key? gallery_month
        year[gallery_year][gallery_month] = Hash.new
      end
      gallery_day = gallery.date.day
      unless year[gallery_year][gallery_month].has_key? gallery_day
        year[gallery_year][gallery_month][gallery_day] = Array.new
      end
      year[gallery_year][gallery_month][gallery_day].push gallery
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
  def initialize config, elements, tag
    @config = config
    @posts = elements
    @tag = tag
  end

  def tag
    @tag
  end
end

class Contents < ContentAccess
  def initialize config
    @config = config
    @post_files = Dir.glob(File.join("_posts", MdContent.glob)).sort
    @posts = Array.new
    @post_tags = Hash.new
    @gallery_files = (Dir.glob("_galleries/*")-Dir.glob("_galleries/*[\.]*")).sort
    @galleries = Array.new
    @gallery_tags = Hash.new
    @urls = Array.new
    @defaultLinks = if File.exists? "links.md" then "\n" + File.open("links.md", "r:utf-8").read else "" end
  end

  def generate all
    puts "Posts"
    @post_files.each do |name|
      content = PostContent.new name, self
      print "  #{name}"
      if content.published || all
        puts ""
        content.tags.each do |tag|
          if !@post_tags.has_key? tag
            @post_tags[tag] = Array.new
          end
          @post_tags[tag].push content
        end
        content.write_to_site
        @posts.push content
        @urls.push content.url
      else
        puts "\t\t\t[[skipped]]"
      end
    end
    
    puts "Galleries"
    @gallery_files.each do |name|
      content = GallerieContent.new name, self
      print "  #{name}"
      if content.published || all
        puts ""
        content.tags.each do |tag|
          if !@gallery_tags.has_key? tag
            @gallery_tags[tag] = Array.new
          end
          @gallery_tags[tag].push content
        end
        content.write_to_site
        @galleries.push content
        @urls.push content.url
      else
        puts "\t\t\t[[skipped]]"
      end
    end

    puts "Pages"
    Dir.glob(File.join("_pages", MdContent.glob)).sort!.each do |name|
      content = MdContent.new name, self, @post_tags, @gallery_tags
      print "  #{name}"
      if content.published || all
        puts ""
        content.write_to_site
        @urls.push content.url
      else
        puts "\t\t\t[[skipped]]"
      end
    end

    tagFile = File.join "_layouts", "tags.haml"
    if File.exists? tagFile
      puts "Tags posts"
      FileUtils.mkdir_p File.join "_site", "tags", "posts"
      @post_tags.each do |tag, contents|
        puts "  #{tag}"
        outFile = File.join "_site", "tags", "posts", "#{tag}.html"
        scope = TagContents.new @config, contents, tag
        hamlContent = HamlContent.new tagFile, scope
        hamlContent.url = "tags/posts/#{tag}.html"
        html = hamlContent.to_html hamlContent
        File.open(outFile, "w") { |f| f.write html }
        @urls.push hamlContent.url
      end
    end
    
    tagFile = File.join "_layouts", "tags.haml"
    if File.exists? tagFile
      puts "Tags galleries"
      FileUtils.mkdir_p File.join "_site", "tags", "galleries"
      @gallery_tags.each do |tag, contents|
        puts "  #{tag}"
        outFile = File.join "_site", "tags", "galleries", "#{tag}.html"
        scope = TagContents.new @config, contents, tag
        hamlContent = HamlContent.new tagFile, scope
        hamlContent.url = "tags/galleries/#{tag}.html"
        html = hamlContent.to_html hamlContent
        File.open(outFile, "w") { |f| f.write html }
        @urls.push hamlContent.url
      end
    end

    atomFile = File.join "_pages", "atom.xml.haml"
    if File.exists? atomFile
      puts "Atom"
      hamlContent = HamlContent.new atomFile, self
      atom = hamlContent.to_html hamlContent
      hamlContent.url = "atom.xml"
      outFile = File.join "_site", "atom.xml"
      File.open(outFile, "w") { |f| f.write atom }
      @urls.push hamlContent.url
    end

    sitemapFile = File.join "_pages", "sitemap.xml.haml"
    if File.exists? sitemapFile
      puts "Sitemap"
      @urls.push "sitemap.xml"
      hamlContent = HamlContent.new sitemapFile, self
      sitemap = hamlContent.to_html hamlContent
      outFile = File.join "_site", "sitemap.xml"
      File.open(outFile, "w") { |f| f.write sitemap }
    end
  end

  def urls
    @urls
  end

  def defaultLinks
    @defaultLinks
  end
end
