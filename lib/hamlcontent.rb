# encoding: utf-8
require "content.rb"
require 'yaml'

class HamlContent < Content
  MATCHER = /^(.+)(\.haml)$/

  def content
    haml = @plain_content
    hamlengine = Haml::Engine.new haml
    hamlengine.render @scope
  end

  def to_html scope
    @scope = scope
    if layout?
      hamlContent = HamlContent.new File.join("_layouts", "#{layout}.haml"), @contents
      return hamlContent.to_html self
    end
    content
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

    slug, ext = *name.match(MATCHER)
    @slug = slug
    @ext = ext
  end

  def valid?
    @name =~ MATCHER
  end
end
