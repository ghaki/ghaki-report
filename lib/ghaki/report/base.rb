############################################################################
require 'ghaki/logger/mixin'
require 'ghaki/stats/base'

############################################################################
module Ghaki
  module Report
    class Base
      include Ghaki::Logger::Mixin

      ######################################################################
      class << self
        attr_accessor :report_name
      end
      attr_accessor :stats

      ######################################################################
      def initialize opts={}
        self.report_name = opts[:report_name] if opts.has_key?(:report_name)
        @stats = opts[:stats] || Ghaki::Stats::Base.new
        if opts.has_key?(:logger)
          @logger = opts[:logger]
        elsif opts.has_key?(:log_file_name)
          @logger = Ghaki::Logger::Base.new( :file_name => opts[:log_file_name] )
        elsif opts.has_key?(:log_file_handle)
          @logger = Ghaki::Logger::Base.new( :file_handle => opts[:log_file_handle] )
        end
      end

      ######################################################################
      def report_name= title
        self.class.report_name = title
      end

      ######################################################################
      def report_name title=nil
        if title.nil?
          self.class.report_name
        elsif title[0,1] == '.'
          self.class.report_name + title
        else
          title
        end
      end

      ######################################################################
      def minor_report_wrap title=nil, &block
        logger.minor.wrap( report_name(title) ) do
          begin
            block.call
          ensure
            stats.flush self.logger
          end
        end
      end

      ######################################################################
      def major_report_wrap title=nil, &block
        logger.major.wrap( report_name(title) ) do
          begin
            block.call
          ensure
            stats.log_flush self.logger
          end
        end
      end

    end # class
  end # package
end # namespace
############################################################################
