require 'ghaki/report/base'

module Ghaki module Report module BaseTesting
describe Base do

  before(:all) do
    @log = stub_everything()
    @maj = stub_everything()
    @min = stub_everything()
  end

  class MyReport < Base
    self.report_name = 'my_report'
  end

  context 'eigen class' do
    subject { MyReport }
    it { should respond_to :report_name }
    describe '#report_name' do
      it 'specifies report name' do
        MyReport.report_name.should == 'my_report'
      end
    end
  end

  subject do MyReport.new( :logger => @log ) end

  context 'object instance' do
    it { should respond_to :logger }
    it { should respond_to :logger= }
    it { should respond_to :stats }
  end

  describe '#report_name' do
    it 'defaults to eigen report name' do
      subject.report_name == 'my_report'
    end
    it 'accepts normal report name' do
      subject.report_name('quack').should == 'quack'
    end
    it 'accepts period leading report nmae' do
      subject.report_name('.moo').should == 'my_report.moo'
    end
  end

  describe '#report_name=' do
    it 'assigns report name' do
      subject.report_name = 'zap'
      subject.report_name.should == 'zap'
    end
  end

  describe '#minor_report_wrap' do
    it 'calls logger minor mode' do
      @log.expects(:minor).returns(@min).once
      @min.expects(:wrap).with('my_report').once
      subject.minor_report_wrap do end
    end
  end

  describe '#major_report_wrap' do
    it 'calls logger major mode' do
      @log.expects(:major).returns(@maj).once
      @maj.expects(:wrap).with('my_report').once
      subject.major_report_wrap do end
    end
  end

end
end end end
