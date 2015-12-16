# encoding:utf-8
require 'spec_helper'
describe TaxGenerator::FileCreator do
  let(:output_folder) { @output_folder ||= @default_processor.output_folder }
  let(:destinations_file_path) { @destination_path ||= @default_processor.destinations_file_path }
  let(:destination_xml) { @xml ||= Nokogiri::XML(File.open(destinations_file_path), nil, 'UTF-8') }
  let(:taxonomy) { @taxonomy ||= TaxGenerator::TaxonomyTree.new(@default_processor.taxonomy_file_path) }
  let(:subject) { TaxGenerator::FileCreator.new }
  let(:first_destination) { destination_xml.at_xpath('//destination') }

  let(:fake_node) { FakeNode.new('something') }

  let(:atlas_id_value) { 'some atlas id value' }
  let(:atlas_id) { AtlasID.new(atlas_id_value) }

  let(:job) { { atlas_id: atlas_id_value, taxonomy: taxonomy, destination: first_destination } }
  before(:each) do
    subject.stubs(:start_work).returns(true)
    # subject.stubs(:nokogiri_xml).returns(destination_xml)
    # subject.stubs(:create_file).returns(true)
    subject.stubs(:log_message).returns(true)
    # subject.stubs(:get_atlas_details).returns({})
    #    taxonomy.stubs(:[]).returns(fake_node)
    @default_processor.stubs(:register_worker_for_job).returns(true) if @default_processor.alive?
  end

  context 'checks the job keys' do
    before(:each) do
      subject.work(job, @default_processor)
    end

    specify { expect(subject.job).to eq job.stringify_keys }
    specify { expect(subject.job_id).to eq atlas_id_value }
    specify { expect(subject.destination).to eq first_destination }
    specify { expect(subject.processor).to eq @default_processor }
    specify { expect(subject.taxonomy).to_not eq(nil) }
  end

  it 'gets the template name' do
    File.expects(:join).with(root, 'templates', 'template.html.erb')
    subject.template_name
  end
  #
  # xit 'returns the fake node' do
  #   taxonomy.expects(:[]).returns(fake_node)
  #   subject.create_file(atlas_id_value, taxonomy, first_destination)
  # end
  #
  # xit 'creates the file' do
  #   subject.expects(:get_atlas_details).with(fake_node, first_destination).returns({})
  #   subject.create_file(atlas_id_value, taxonomy, first_destination)
  # end
  #
  # xit 'tries to creatte the html' do
  #   subject.expects(:create_html).with(subject.output_folder, atlas_id, {}).returns(true)
  #   subject.create_file(atlas_id_value, taxonomy, first_destination)
  # end
end
