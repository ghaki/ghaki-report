require 'ghaki/core_ext/file/with_temp'
require 'ghaki/report/base'

module Ghaki  #:nodoc:
module Report #:nodoc:

class OutputFile < Base

  ######################################################################
  attr_accessor :output_file

  ######################################################################
  def initialize opts={} ; super opts
    self.class.report_name ||= 'WRITING REPORT'
    @output_file = opts[:output_file]
  end

  ######################################################################
  def output_report
    output_prepare
    logger.info 'output file: ' + @output_file
    File.with_opened_temp @output_file do |tmp_file|
      output_to_format tmp_file
    end
    output_finish
  end

  ######################################################################
  def output_finish
  end

  ######################################################################
  def output_prepare
  end

  ######################################################################
  def output_to_format out_file
  end

end
end end
