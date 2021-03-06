require 'logger'

module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger= logger
  	@logger = logger
  end
end