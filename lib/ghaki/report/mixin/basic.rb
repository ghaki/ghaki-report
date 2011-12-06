require 'ghaki/logger/mixin'
require 'ghaki/stats/mixin'

module Ghaki  #:nodoc:
module Report #:nodoc:
module Mixin  #:nodoc:

module Basic
  include Ghaki::Logger::Mixin
  include Ghaki::Stats::Mixin

  module ClassMethods
    attr_accessor :report_name
  end

  def self.included klass #:nodoc:
    klass.extend ClassMethods
  end

  def initialize opts={}
    self.report_name = opts[:report_name] unless opts[:report_name].nil?
    @stats = opts[:stats]
    if not opts[:logger].nil?
      @logger = opts[:logger]
    elsif not opts[:log_file_name].nil?
      @logger = Ghaki::Logger::Base.new( :file_name => opts[:log_file_name] )
    elsif not opts[:log_file_handle].nil?
      @logger = Ghaki::Logger::Base.new( :file_handle => opts[:log_file_handle] )
    end
  end

  def report_name= title
    if title.nil?
      @report_name = self.class.report_name
    elsif title[0,1] == '.'
      @report_name = (@report_name || self.class.report_name) + title
    else
      @report_name = title
    end
  end

  def report_name title=nil
    if title.nil?
      @report_name || self.class.report_name
    elsif title[0,1] == '.'
      (@report_name || self.class.report_name) + title
    else
      title
    end
  end

  def minor_report_wrap title=nil, &block
    logger.minor.wrap( report_name(title) ) do
      begin
        block.call
      ensure
        stats.flush self.logger
      end
    end
  end

  def major_report_wrap title=nil, &block
    logger.major.wrap( report_name(title) ) do
      begin
        block.call
      ensure
        stats.flush self.logger
      end
    end
  end

end
end end end
