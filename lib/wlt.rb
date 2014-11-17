# encoding: utf-8
require "yaml"
require "fileutils"
require "sass"
require 'coffee-script'


require "contents.rb"
require "colored.rb"

class Wlt
  def initialize local = false
    raise "Not a valid Web Log Today location" unless valid_location?
    @config = YAML.load File.open("config.yaml", "r:utf-8").read
    @config["__site_url__"] = @config["site_url"]
    @config["site_url"] = "http://localhost:4000" if local
  end

  def generate all = false
    init
    css
    js
    contents all
    pub
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

    puts "Css".blue
    cssconf.each do |cssname|
      syntax = :sass
      application_css = File.join "_css", "#{cssname}.sass"
      unless File.exists? application_css
        syntax = :scss
        application_css = File.join "_css", "#{cssname}.scss"
      end
      next unless File.exists? application_css
      sassengine = Sass::Engine.for_file(application_css, :syntax => syntax, :style => :compressed)
      css = sassengine.render

      File.open("_site/#{cssname.split('/').last}.css", "w") { |f| f.write(css) }
      puts "  #{cssname}"
    end
  end

  def js
    return unless @config.has_key? "assets"
    return unless @config["assets"].has_key? "js"
    jsconf = @config["assets"]["js"]
    return unless jsconf.kind_of? Array

    puts "Js".blue
    jsconf.each do |jsname|
      application_js = File.join "_js", "#{jsname}.coffee"
      next unless File.exists? application_js
      js = CoffeeScript.compile File.open(application_js, "r:utf-8").read
      File.open("_site/#{jsname}.js", "w") { |f| f.write(js) }
      puts "  #{jsname}"
    end
  end

  def pub
    FileUtils.cp_r File.join('_pub', '.') , '_site'
    puts "Pub".blue
  end

  def contents all
    contents = Contents.new @config
    contents.generate all
  end

  def deploy
    sh "rsync --checksum -rtzh --progress --delete _site/ #{@config["deploy_to"]}"
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