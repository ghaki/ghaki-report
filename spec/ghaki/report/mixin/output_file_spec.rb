require 'ghaki/report/mixin/basic'
require 'ghaki/report/mixin/output_file'
require 'ghaki/logger/spec_helper'
require 'ghaki/stats/spec_helper'
require 'ghaki/core_ext/file/spec_helper/fake_temp'

module Ghaki module Report module Mixin module OutputFileTesting
describe OutputFile do
  include Ghaki::Logger::SpecHelper
  include Ghaki::Stats::SpecHelper
  include Ghaki::CoreExt::File::SpecHelper::FakeTemp

  FAKE_OUT = '/tmp/myfile.txt'

  class MyReport
    include Ghaki::Report::Mixin::Basic
    include Ghaki::Report::Mixin::OutputFile
  end

  before(:each) do
    setup_safe_stats
    reset_safe_logger
    setup_fake_tempfile
    @subj = MyReport.new({
      :logger => @logger,
      :stats  => @stats,
      :output_file => FAKE_OUT,
    })
  end

  subject { @subj }

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
      subject.expects(:output_to_format).with(@fake_tempfile).once.in_sequence(abc)
      subject.expects(:output_finish).once.in_sequence(abc)
      subject.output_report
    end
  end

end
end end end end
