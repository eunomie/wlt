
class Comment
  def initialize name
    @name = name
    @datas = Hash.new
    @plain_content = ""

    read
  end

  def content
    lines = @plain_content.split "\n"
    "<p>#{lines.join "</p><p>"}</p>"
  end

  def read
    raise "File #{@name} doesn't exists" if !File.exists? @name

    @plain_content = File.open(@name, "r:utf-8").read
    begin
      if @plain_content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @plain_content = $'
        @datas = YAML.load $1
      end
    rescue => e
      puts "YAML Exception reading #{@name}: #{e.message}"
    end
  end

  def method_missing(m, *args, &block)
    if m =~ /^(.*)\?$/
      return @datas.has_key? $1
    elsif @datas.has_key? m.to_s
      return @datas[m.to_s]
    else
      return nil
    end
  end
end