# encoding: utf-8
require "postcontent.rb"
require "mdcontent.rb"

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
  def initialize config, elements, tag
    @config = config
    @all = elements
    @tag = tag
  end

  def tag
    @tag
  end
end

class Contents < ContentAccess
  def initialize config
    @config = config
    @files = Dir.glob(File.join("_posts", MdContent.glob)).sort
    @all = Array.new
    @tags = Hash.new
    @urls = Array.new
    @defaultLinks = if File.exists? "links.md" then "\n" + File.open("links.md", "r:utf-8").read else "" end
  end

  def generate all
    puts "Posts"
    @files.each do |name|
      content = PostContent.new name, self
      print "  #{name}"
      if content.published || all
        puts ""
        content.tags.each do |tag|
          if !@tags.has_key? tag
            @tags[tag] = Array.new
          end
          @tags[tag].push content
        end
        content.write_to_site
        @all.push content
        @urls.push content.url
      else
        puts "\t\t\t[[skipped]]"
      end
    end

    puts "Pages"
    Dir.glob(File.join("_pages", MdContent.glob)).sort!.each do |name|
      content = MdContent.new name, self
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
      puts "Tags"
      FileUtils.mkdir_p File.join "_site", "tags"
      @tags.each do |tag, contents|
        puts "  #{tag}"
        outFile = File.join "_site", "tags", "#{tag}.html"
        scope = TagContents.new @config, contents, tag
        hamlContent = HamlContent.new tagFile, scope
        hamlContent.url = "tags/#{tag}.html"
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
