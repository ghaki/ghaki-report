require 'mocha_helper'
require 'ghaki/report/base'
require 'ghaki/report/mixin/linear_parser'

module Ghaki module Report module Mixin module LinearParserTesting
describe LinearParser do

  before(:all) do
    @log = stub_everything()
  end

  class MyParser < Base
    include LinearParser
  end

  before(:each) do
    @parser = MyParser.new( :logger => @log )
  end

  subject do @parser end

  context 'including objects' do
    it { should respond_to :parser_engine }
    it { should respond_to :parser_unknown_max }
    it { should respond_to :parser_unknown }
    it { should respond_to :parser_matched }
    it { should respond_to :parser_skipped }
    it { should respond_to :parser_invalid }
    it { should respond_to :parser_error_max }
    it { should respond_to :parser_error }
    it { should respond_to :parser_warn_max }
    it { should respond_to :parser_warn }
  end

  before(:each) do
    subject.stats.clear
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
      @log.expects(:warn).once
      @log.expects(:puts).once
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
      @log.expects(:warn).once
      @log.expects(:puts).once
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
      @log.expects(:error).once
      @log.expects(:puts).once
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
      @log.expects(:error).once
      @log.expects(:puts).once
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
