require "yaml"
require "fileutils"
require "sass"

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
    puts "Css"
    @config["assets"]["css"].each do |cssname|
      application_css = File.join "_css", "#{cssname}.sass"
      next unless File.exists? application_css
      sassengine = Sass::Engine.for_file(application_css, :syntax => :sass, :style => :compressed)
      css = sassengine.render

      File.open("_site/#{cssname}.css", "w") { |f| f.write(css) }
      puts "  #{cssname}"
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