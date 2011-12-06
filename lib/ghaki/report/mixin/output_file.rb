require 'ghaki/core_ext/file/with_temp'

module Ghaki  #:nodoc:
module Report #:nodoc:
module Mixin  #:nodoc:

module OutputFile

  attr_accessor :output_file

  def initialize opts={} ; super opts
    @output_file = opts[:output_file]
  end

  def output_report
    output_prepare
    File.with_opened_temp @output_file do |tmp_file|
      output_to_format tmp_file
    end
    output_finish
  end

  def output_finish
  end

  def output_prepare
    logger.info 'output file: ' + @output_file
  end

  def output_to_format out_file
  end

end
end end end
