# encoding:utf-8
require 'spec_helper'
describe TaxGenerator::FileCreator do
  let(:output_folder) {"some_other_path" }
  let(:destinations_file_path) {  "some_path" }
  let(:destination_xml) { "some_xml" }
  let(:subject) { TaxGenerator::FileCreator.new }
  let(:first_destination) { "some destination" }

  let(:fake_node) { FakeNode.new('something') }

  let(:atlas_id_value) { 'some atlas id value' }
  let(:atlas_id) { AtlasID.new(atlas_id_value) }
  let(:fake_tilt) {FakeTilt.new}

  let(:job) { { atlas_id: atlas_id_value, taxonomy: fake_node, destination: first_destination, output_folder: output_folder } }
  before(:each) do
    destination_xml.stubs(:at_xpath).returns(fake_node)
    destination_xml.stubs(:xpath).returns([fake_node])
    subject.stubs(:start_work).returns(true)
    subject.stubs(:log_message).returns(true)
    @default_processor.stubs(:register_worker_for_job).returns(true) if @default_processor.alive?
    File.stubs(:open).returns(true)
    Tilt.stubs(:new).returns(fake_tilt)
    fake_tilt.stubs(:render).returns(true)
    subject.stubs(:mark_job_completed).returns(true)
  end

  context 'checks the job keys' do
    before(:each) do
      subject.work(job, @default_processor)
    end

    specify { expect(subject.job).to eq job.stringify_keys }
    specify { expect(subject.processor).to eq @default_processor }
  end

  context 'processes the job' do
    before(:each) do
      subject.process_job(job)
    end

    specify { expect(subject.job_id).to eq atlas_id_value }
    specify { expect(subject.destination).to eq first_destination }
    specify { expect(subject.output_folder).to eq(output_folder) }
    specify { expect(subject.taxonomy).to eq(fake_node) }
  end

  it 'gets the template name' do
    File.expects(:join).with(root, 'templates', 'template.html.erb')
    subject.template_name
  end


  it 'gets start work' do
    Actor.expects(:current).returns("ahah")
   fake_tilt.expects(:render).returns(true)
    subject.start_work
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
