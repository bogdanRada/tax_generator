# encoding:utf-8
require 'spec_helper'
describe TaxGenerator::Destination do
  let(:str) { @default_processor.destinations_file_path }

  let(:destination_xml) { @xml ||= Nokogiri::XML(File.open(str), nil, 'UTF-8') }
  let(:info_base) { './/practical_information/health_and_safety' }
  before(:each) do
    @destination = TaxGenerator::Destination.new(destination_xml)
  end

  context 'xpaths' do
    it 'fetches the introduction' do
      destination_xml.expects(:xpath).with('.//introductory/introduction/overview').returns(true)
      @destination.introduction
    end

    it 'fetches the history' do
      destination_xml.expects(:xpath).with('./history/history/history').returns(true)
      @destination.history
    end

    ['dangers_and_annoyances', 'while_youre_there', 'before_you_go', 'money_and_costs/money'].each do |name|
      it "fetches the practical_information with #{name}" do
        destination_xml.stubs(:xpath).returns([])
        destination_xml.expects(:xpath).with(".//practical_information/health_and_safety/#{name}").returns([])
        @destination.practical_information
      end
    end

    it 'fetches the transport' do
      destination_xml.expects(:xpath).with('.//transport/getting_around').returns(true)
      @destination.transport
    end

    it 'fetches the weather' do
      destination_xml.expects(:xpath).with('.//weather').returns(true)
      @destination.weather
    end

    it 'fetches the work_live_study' do
      destination_xml.expects(:xpath).with('.//work_live_study').returns(true)
      @destination.work_live_study
    end
  end

  it 'returns the hash' do
    expect(@destination.to_hash).to eq(
      {
        introduction: @destination.introduction,
        history: @destination.history,
        practical_information: @destination.practical_information,
        transport:  @destination.transport,
        weather: @destination.weather,
        work_live_study: @destination.work_live_study
      }.each_with_object({}) do |(key, value), hsh|
        hsh[key] = elements_with_content(value)
        hsh
      end)
  end
end
