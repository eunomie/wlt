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
    }.inject(":year/:month/:day/:title.html") { |result, token|
      result.gsub(/:#{Regexp.escape token.first}/, token.last)
    }.gsub(/\/\//, "/")
  end

  def full_title
    "#{formated_date} : #{title}"
  end

  def formated_date
    @date.strftime("%d/%m/%Y")
  end
end
