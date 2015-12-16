# encoding:utf-8
require 'spec_helper'
describe TaxGenerator::Processor do
  let(:subject) {TaxGenerator::Processor.new}

  # it 'parses the xml' do
  #   subject.expects(:nokogiri_xml).with(destinations_file_path).returns(destination_xml)
  #   actual = subject.destinations
  #   expect(actual).to eq destination_xml
  # end
  #
  # it 'generates the files with 0' do
  #   subject.expects(:create_file).with(0, taxonomy, nil).returns(true)
  #   subject.generate_files(taxonomy)
  # end
  #
  # it 'searches the destinations' do
  #   subject.destinations.expects(:xpath).with('//destination').returns([])
  #   subject.generate_files(taxonomy)
  # end
  #
  # it 'tries to create all the files for all destinations' do
  #   destination_xml.xpath('//destination').each do |destination|
  #     destination.expects(:attributes).returns('atlas_id' => atlas_id)
  #     subject.expects(:create_file).with(atlas_id.value, taxonomy, destination).returns(true)
  #   end
  #   subject.generate_files(taxonomy)
  # end

end
