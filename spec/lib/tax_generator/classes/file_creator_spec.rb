# encoding:utf-8
require 'spec_helper'
describe TaxGenerator::FileCreator do
  let(:default_processor) {TaxGenerator::Processor.new}
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
    default_processor.stubs(:register_worker_for_job).returns(true)
    File.stubs(:open).returns(true)
    Tilt.stubs(:new).returns(fake_tilt)
    fake_tilt.stubs(:render).returns(true)
    subject.stubs(:mark_job_completed).returns(true)
    default_processor.stubs(:all_workers_finished).returns(false)
  end

  context 'checks the job keys' do
    before(:each) do
      subject.work(job, default_processor)
    end

    specify { expect(subject.job).to eq job.stringify_keys }
    specify { expect(subject.processor).to eq default_processor }
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

  context "job related " do

    before(:each) do

      subject.work(job, default_processor)
      default_processor.stubs(:register_worker_for_job).returns(true)
    end

    it 'gets start work' do
      details = {details: fake_node, root: root}
      Actor.stubs(:current).returns(subject)
      subject.stubs(:fetch_atlas_details).returns(details)
      fake_tilt.stubs(:render).with(subject,details).returns(true)
      subject.start_work
    end

    it 'mark_job_completed' do
      default_processor.register_jobs(job)
      subject.mark_job_completed
      expect(subject.processor.jobs[subject.job_id]).to eq(job.stringify_keys)
    end

    it 'fetch_atlas_details' do
      subject.taxonomy.expects(:[]).with(subject.job_id).returns(fake_node)
      TaxGenerator::Destination.expects(:new).with(first_destination).returns(first_destination)
      first_destination.stubs(:to_hash).returns({})
      actual = subject.fetch_atlas_details
      expect(actual).to eq({details: fake_node})
    end
  end

end
