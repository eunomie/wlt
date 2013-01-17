require "yaml"
require "fileutils"
require "sass"
require 'coffee-script'


require "contents.rb"

class Wlt
  def initialize
    raise "Not a valid Web Log Today location" unless valid_location?
    @config = YAML.load File.read "config.yaml"
  end

  def init
    FileUtils.mkdir_p "_site"
    FileUtils.rm_rf Dir.glob "_site/*"
  end

  def css
    return unless @config.has_key? "assets"
    return unless @config["assets"].has_key? "css"
    cssconf = @config["assets"]["css"]
    return unless cssconf.kind_of? Array

    puts "Css"
    cssconf.each do |cssname|
      application_css = File.join "_css", "#{cssname}.sass"
      next unless File.exists? application_css
      sassengine = Sass::Engine.for_file(application_css, :syntax => :sass, :style => :compressed)
      css = sassengine.render

      File.open("_site/#{cssname}.css", "w") { |f| f.write(css) }
      puts "  #{cssname}"
    end
  end

  def js
    return unless @config.has_key? "assets"
    return unless @config["assets"].has_key? "js"
    jsconf = @config["assets"]["js"]
    return unless jsconf.kind_of? Array

    puts "Js"
    jsconf.each do |jsname|
      application_js = File.join "_js", "#{jsname}.coffee"
      next unless File.exists? application_js
      js = CoffeeScript.compile File.read application_js
      File.open("_site/#{jsname}.js", "w") { |f| f.write(js) }
      puts "  #{jsname}"
    end

  end

  private
  def valid_location?
    return false unless File.exists? "config.yaml"
    return false unless File.directory? "_posts"
    return false unless File.directory? "_pages"
    return false unless File.directory? "_layouts"
    return true
  end
end