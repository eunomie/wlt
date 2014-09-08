# encoding: utf-8
require "mdcontent.rb"
require 'time'

class PostContent < MdContent
  def initialize(name, contents)
    super(name, contents)
  end

  def url
    {
      "year"  => @date.strftime("%Y"),
      "month" => @date.strftime("%m"),
      "day"   => @date.strftime("%d"),
      "title" => CGI.escape(@slug)
    }.inject("posts/:year/:month/:day/:title.html") { |result, token|
      result.gsub(/:#{Regexp.escape token.first}/, token.last)
    }.gsub(/\/\//, "/")
  end

  def full_title
    "#{formated_date} : #{title}"
  end

  def formated_date
    @date.strftime("%d/%m/%Y")
  end

  protected

  def read_comments
    cleanurl = @contents.config["__site_url__"].gsub('http://', '').gsub('https://', '')
    cleanfilename = File.basename(@name, ".md")
    glob = File.join("_comments", cleanurl, cleanfilename, "*.md")
    comment_files = Dir.glob(glob).sort.each do |file|
      @comments.push Comment.new file
    end
  end
end
