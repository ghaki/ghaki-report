require 'ghaki/report/mixin/basic'
require 'ghaki/logger/spec_helper'
require 'ghaki/stats/spec_helper'

module Ghaki module Report module Mixin module Basic_Testing
describe Basic do
  include Ghaki::Logger::SpecHelper
  include Ghaki::Stats::SpecHelper

  SET_NAME = 'SET_NAME'
  DEF_NAME = 'DEFAULT_NAME'
  SUB_NAME = '.SUB_NAME'
  SET_SUB_FULL = 'SET_NAME.SUB_NAME'
  DEF_SUB_FULL = 'DEFAULT_NAME.SUB_NAME'

  class MyReport
    include Ghaki::Report::Mixin::Basic
    self.report_name = DEF_NAME
  end

  context 'meta class' do
    subject { MyReport }
    it { should respond_to :report_name  }
    it { should respond_to :report_name= }
  end

  context 'object instance' do

    before(:each) do
      setup_safe_stats
      reset_safe_logger
      @my_report = MyReport.new({
        :logger => @logger,
        :stats  => @stats,
      })
    end

    subject { @my_report }

    it { should be_kind_of(Ghaki::Logger::Mixin) }
    it { should be_kind_of(Ghaki::Stats::Mixin) }

    it { should respond_to :logger  }
    it { should respond_to :logger= }
    it { should respond_to :stats  }
    it { should respond_to :stats= }

    describe '#initialize' do
      context 'using option :report_name' do
        it 'accepts full name' do
          MyReport.new( :report_name => SET_NAME ).report_name == SET_NAME
        end
        it 'defaults to meta report name' do
          MyReport.new.report_name.should == DEF_NAME
        end
        it 'accepts partial name using default' do
          MyReport.new( :report_name => SUB_NAME ).report_name == DEF_SUB_FULL
        end
      end
      context 'using option :stats' do
        it 'defaults' do
          Ghaki::Stats::Base.expects(:new).returns(@stats)
          MyReport.new.
            stats.should == @stats
        end
        it 'accepts' do
          MyReport.new( :stats => @stats ).
            stats.should == @stats
        end
      end
      context 'using option :logger' do
        it 'defaults' do
          Ghaki::Logger::Base.expects(:new).returns(@logger)
          MyReport.new.
            logger.should == @logger
        end
        it 'accepts' do
          MyReport.new( :logger => @logger).
            logger.should == @logger
        end
      end
    end

    describe '#report_name' do
      it 'defaults to meta report name' do
        subject.report_name.should == DEF_NAME
      end
      it 'accepts full report name' do
        subject.report_name(SET_NAME).should == SET_NAME
      end
      it 'accepts partial name with default' do
        subject.report_name(SUB_NAME).should == DEF_SUB_FULL
      end
      it 'accepts partial name after override' do
        subject.report_name = SET_NAME
        subject.report_name(SUB_NAME).should == SET_SUB_FULL
      end
    end

    describe '#report_name=' do
      it 'assigns report name' do
        subject.report_name = SET_NAME
        subject.report_name.should == SET_NAME
      end
      it 'resets to default name on nil' do
        subject.report_name = SET_NAME
        subject.report_name = nil
        subject.report_name.should == DEF_NAME
      end
      it 'accepts partial name with default' do
        subject.report_name = SUB_NAME
        subject.report_name.should == DEF_SUB_FULL
      end
      it 'accepts partial name after override' do
        subject.report_name = SET_NAME
        subject.report_name = SUB_NAME
        subject.report_name.should == SET_SUB_FULL
      end
    end

    describe '#minor_report_wrap' do
      it 'calls logger minor mode with default report name' do
        @logger.minor.expects(:wrap).with(DEF_NAME).once
        subject.minor_report_wrap do end
      end
      it 'calls logger minor mode with given report name' do
        @logger.minor.expects(:wrap).with(SET_NAME).once
        subject.minor_report_wrap SET_NAME do end
      end
    end

    describe '#major_report_wrap' do
      it 'calls logger major mode with default report name' do
        @logger.major.expects(:wrap).with(DEF_NAME).once
        subject.major_report_wrap do end
      end
      it 'calls logger major mode with given report name' do
        @logger.major.expects(:wrap).with(SET_NAME).once
        subject.major_report_wrap SET_NAME do end
      end
    end

  end
end
end end end end
