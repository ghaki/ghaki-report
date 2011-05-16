require 'mocha_helper'
require 'ghaki/report/output_file'

module Ghaki module Report module OutputFileTesting
describe OutputFile do

  before(:all) do
    @log = stub_everything()
    @out = '/tmp/myfile.txt'
  end

  subject do OutputFile.new( :logger => @log, :output_file => @out ) end

  it { should respond_to :output_file }
  it { should respond_to :output_file= }
  it { should respond_to :output_report }
  it { should respond_to :output_finish }
  it { should respond_to :output_prepare }
  it { should respond_to :output_to_format }

  describe '#output_report' do
    it 'should create file' do
      abc = sequence('reporting')
      subject.expects(:output_prepare).once.in_sequence(abc)
      ::File.expects(:with_opened_temp).with(@out).yields(@out).once.in_sequence(abc)
      subject.expects(:output_to_format).with(@out).once.in_sequence(abc)
      subject.expects(:output_finish).once.in_sequence(abc)
      subject.output_report
    end
  end

end
end end end
