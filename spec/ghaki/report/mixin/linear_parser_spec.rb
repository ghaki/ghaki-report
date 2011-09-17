require 'ghaki/logger/spec_helper'
require 'ghaki/stats/spec_helper'
require 'ghaki/report/base'
require 'ghaki/report/mixin/linear_parser'

module Ghaki module Report module Mixin module LinearParser_Testing
describe LinearParser do
  include Ghaki::Logger::SpecHelper
  include Ghaki::Stats::SpecHelper

  class MyParser < Base
    include LinearParser
  end

  before(:each) do
    setup_safe_stats
    setup_safe_logger
    @parser = MyParser.new({
      :logger => @logger,
      :stats  => @stats,
    })
  end

  subject do @parser end

  it { should respond_to :parser_curr_line }
  it { should respond_to :parser_curr_lcnt }
  it { should respond_to :parser_unknown_max  }
  it { should respond_to :parser_unknown_max= }
  it { should respond_to :parser_error_max  }
  it { should respond_to :parser_error_max= }
  it { should respond_to :parser_warn_max  }
  it { should respond_to :parser_warn_max= }

  before(:each) do
    @stats.clear
  end

  describe '#parser_startup' do
    it 'defaults parser unknown max' do
      subject.parser_unknown_max = nil
      subject.parser_startup
      subject.parser_unknown_max.should == LinearParser::PARSER_UNKNOWN_MAX_DEF
    end
    it 'defaults parser warning max' do
      subject.parser_warn_max = nil
      subject.parser_startup
      subject.parser_warn_max.should == LinearParser::PARSER_WARN_MAX_DEF
    end
    it 'defaults parser error max' do
      subject.parser_error_max = nil
      subject.parser_startup
      subject.parser_error_max.should == LinearParser::PARSER_ERROR_MAX_DEF
    end
    it 'zeroes parser stats' do
      subject.expects(:parser_reset_stats).once
      subject.parser_startup
    end
    it 'resets parser state' do
      subject.expects(:parser_reset_state).once
      subject.parser_startup
    end
  end

  describe '#parser_cleanup' do
    it { should respond_to :parser_cleanup }
  end

  describe '#parser_advance' do
    before(:each) do
      subject.parser_startup
    end
    it 'increments line count' do
      subject.parser_advance 'junk'
      subject.parser_curr_lcnt.should == 1
    end
    it 'sets current line' do
      subject.parser_advance 'junk'
      subject.parser_curr_line.should  == 'junk'
    end
    it 'increments input lines read' do
      subject.parser_advance 'junk'
      @stats.get('Input Lines','Read').should == 1
    end
  end

  describe '#parser_engine' do
    it 'calls parser startup' do
      subject.parser_startup # do actual init
      subject.expects(:parser_startup).once # test for init
      subject.parser_engine "\njunk\njunk\n" do
        # do nothing
      end
    end
    it 'calls parser advance for each line' do
      subject.expects(:parser_advance).times(3)
      subject.parser_engine "\njunk\njunk\n" do
        # do nothing
      end
    end
    it 'yields for each line' do
      cnt = 0
      subject.parser_engine "\njunk\njunk\n" do
        cnt += 1
      end
      cnt.should == 3
    end
    it 'calls parser cleanup' do
      subject.expects(:parser_cleanup)
      subject.parser_engine "\njunk\njunk\n" do
        # do nothing
      end
    end
  end

  describe '#parser_reset_stats' do
    it 'clears existing stats' do
      @stats.expects(:clear).once
      subject.parser_reset_stats
    end
    it 'zeroes input lines read' do
      @stats.put( 'Input Lines', 'Read', 20 )
      subject.parser_reset_stats
      @stats.get('Input Lines','Read').should == 0
    end
    it 'zeroes input lines skipped' do
      @stats.put( 'Input Lines', 'Skipped', 20 )
      subject.parser_reset_stats
      @stats.get('Input Lines','Skipped').should == 0
    end
    it 'zeroes input lines matched' do
      @stats.put( 'Input Lines', 'Matched', 20 )
      subject.parser_reset_stats
      @stats.get('Input Lines','Matched').should == 0
    end
    it 'zeroes input lines invalid' do
      @stats.put( 'Input Lines', 'Invalid', 20 )
      subject.parser_reset_stats
      @stats.get('Input Lines','Invalid').should == 0
    end
    it 'zeroes input lines unknown' do
      @stats.put( 'Input Lines', 'Unknown', 20 )
      subject.parser_reset_stats
      @stats.get('Input Lines','Unknown').should == 0
    end
  end

  describe '#parser_matched' do
    it 'increments counters' do
      subject.parser_matched 'Zap'
      subject.stats.get('Input Lines','Matched').should == 1
      subject.stats.get('Matched Lines','Zap').should == 1
    end
  end

  describe '#parser_skipped' do
    it 'increments counters' do
      subject.parser_skipped 'Whitespace'
      subject.stats.get('Input Lines','Skipped').should == 1
      subject.stats.get('Skipped Lines','Whitespace').should == 1
    end
  end

  describe '#parser_unknown' do
    before(:each) do
      @logger.expects(:warn).once
      @logger.expects(:puts).once
    end
    it 'increments counters' do
      subject.parser_unknown_max = 10
      subject.parser_engine 'junk' do
        subject.parser_unknown
      end
      subject.stats.get('Input Lines','Unknown').should == 1
    end
    it 'alarms at threshold at one' do
      subject.parser_unknown_max = 1
      lambda do
        subject.parser_engine 'junk' do
          subject.parser_unknown
        end
      end.should raise_error(ReportContentError,%r{Unknown\sInput})
    end
    it 'alarms at threshold at many' do
      subject.parser_unknown_max = 10
      lambda do
        subject.parser_engine 'junk' do
          subject.stats.put('Input Lines','Unknown',10)
          subject.parser_unknown
        end
      end.should raise_error(ReportContentError,%r{Unknown\sLine\sMaximum})
    end
  end

  describe '#parser_warn' do
    before(:each) do
      @logger.expects(:warn).once
      @logger.expects(:puts).once
    end
    it 'increments counters' do
      subject.parser_warn_max = 10
      subject.parser_engine 'junk' do
        subject.parser_warn
      end
      subject.stats.get('Parser State','Warnings').should == 1
    end
    it 'alarms at threshold of one' do
      subject.parser_warn_max = 1
      lambda do
        subject.parser_engine 'junk' do
          subject.parser_warn
        end
      end.should raise_error(ReportContentError,%r{Parser\sWarning})
    end
    it 'alarms at threshold of many' do
      subject.parser_warn_max = 10
      lambda do
        subject.parser_engine 'junk' do
          subject.stats.put('Parser State','Warnings',10)
          subject.parser_warn
        end
      end.should raise_error(ReportContentError,%r{Parser\sWarning\sMaximum})
    end
  end

  describe '#parser_error' do
    before(:each) do
      @logger.expects(:error).once
      @logger.expects(:puts).once
    end
    it 'increments counters' do
      subject.parser_error_max = 10
      subject.parser_engine 'junk' do
        subject.parser_error
      end
      subject.stats.get('Parser State','Errors').should == 1
    end
    it 'alarms at threshold of one' do
      subject.parser_error_max = 1
      lambda do
        subject.parser_engine 'junk' do
          subject.parser_error
        end
      end.should raise_error(ReportContentError,%r{Parser\sError})
    end
    it 'alarms at threshold of many' do
      subject.parser_error_max = 10
      lambda do
        subject.parser_engine 'junk' do
          subject.stats.put('Parser State','Errors',10)
          subject.parser_error
        end
      end.should raise_error(ReportContentError,%r{Parser\sError\sMaximum})
    end
  end

  describe '#parser_invalid' do
    before(:each) do
      @logger.expects(:error).once
      @logger.expects(:puts).once
    end
    it 'increments counters' do
      subject.parser_error_max = 10
      subject.parser_engine 'junk' do
        subject.parser_invalid
      end
      subject.stats.get('Input Lines','Invalid').should == 1
    end
    it 'alarms at threshold of one' do
      subject.parser_error_max = 1
      lambda do
        subject.parser_engine 'junk' do
          subject.parser_invalid
        end
      end.should raise_error(ReportContentError,%r{Invalid\sLine})
    end
    it 'alarms at threshold of many' do
      subject.parser_error_max = 10
      lambda do
        subject.parser_engine 'junk' do
          subject.stats.put('Parser State','Errors',10)
          subject.parser_invalid
        end
      end.should raise_error(ReportContentError,%r{Parser\sError\sMaximum})
    end
  end

end
end end end end
