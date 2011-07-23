require 'ghaki/report/errors'

module Ghaki  #:nodoc:
module Report #:nodoc:
module Mixin  #:nodoc:

module LinearParser

  PARSER_UNKNOWN_UNLIMITED = 0
  PARSER_UNKNOWN_MAX_DEF = PARSER_UNKNOWN_UNLIMITED

  PARSER_WARN_UNLIMITED = 0
  PARSER_WARN_MAX_DEF = 10

  PARSER_ERROR_UNLIMITED = 0
  PARSER_ERROR_MAX_DEF = 1

  attr_reader :parser_curr_line, :parser_curr_lcnt
  attr_accessor :parser_unknown_max,
    :parser_error_max, :parser_warn_max

  def parser_startup
    @parser_unknown_max ||= PARSER_UNKNOWN_MAX_DEF
    @parser_warn_max    ||= PARSER_WARN_MAX_DEF
    @parser_error_max   ||= PARSER_ERROR_MAX_DEF
    parser_reset_stats
    parser_reset_state
  end

  def parser_reset_state
    @parser_curr_lcnt = 0
  end

  def parser_reset_stats
    stats.clear
    stats.def_zero 'Input Lines', 'Read'
    stats.def_zero 'Input Lines', 'Skipped'
    stats.def_zero 'Input Lines', 'Matched'
    stats.def_zero 'Input Lines', 'Invalid'
    stats.def_zero 'Input Lines', 'Unknown'
  end

  def parser_cleanup
  end

  def parser_advance line
    @parser_curr_lcnt += 1
    @parser_curr_line = line
    stats.incr 'Input Lines', 'Read'
  end

  def parser_engine text, &block
    parser_startup
    text.each_line do |line|
      parser_advance line
      block.call( line )
    end
    parser_cleanup
  end

  #
  # PARSING STATUS
  #

  def parser_matched msg=''
    stats.incr 'Input Lines', 'Matched'
    stats.incr 'Matched Lines', msg unless msg.empty?
  end

  def parser_skipped msg='Expected'
    stats.incr 'Input Lines', 'Skipped'
    stats.incr 'Skipped Lines', msg
  end

  def parser_unknown msg='Unknown Input'
    logger.warn "#{msg} At Line #{@parser_curr_lcnt}"
    logger.puts @parser_curr_line
    _parser_unknown_check msg
  end

  def parser_invalid msg='Invalid Line'
    stats.incr 'Input Lines', 'Invalid'
    parser_error msg
  end

  def parser_error msg='Parser Error'
    logger.error "#{msg} At Line #{@parser_curr_lcnt}"
    logger.puts @parser_curr_line
    _parser_error_check msg
  end

  def parser_warn msg='Parser Warning'
    logger.warn "#{msg} At Line #{@parser_curr_lcnt}"
    logger.puts @parser_curr_line
    _parser_warn_check msg
  end


  #
  # PARSER STATE CHECKS
  #

  def _parser_basic_check msg, max, unl, maj, min, exc
    stats.incr maj, min
    return if max == unl
    raise ReportContentError, msg if max == 1
    cnt = stats.get( maj, min )
    if cnt >= max
      raise ReportContentError, exc + ' Maximum Exceeded: ' + cnt.to_s
    end
  end

  def _parser_error_check msg
    _parser_basic_check( msg,
                       @parser_error_max, PARSER_ERROR_UNLIMITED,
                       'Parser State', 'Errors',
                       'Parser Error' )
  end

  def _parser_warn_check msg
    _parser_basic_check( msg,
                       @parser_warn_max, PARSER_WARN_UNLIMITED,
                       'Parser State', 'Warnings',
                       'Parser Warning' )
  end

  def _parser_unknown_check msg
    _parser_basic_check( msg,
                       @parser_unknown_max, PARSER_UNKNOWN_UNLIMITED,
                       'Input Lines', 'Unknown',
                       'Unknown Line' )
  end

end
end end end
