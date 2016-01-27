# encoding:utf-8
require 'spec_helper'
describe TaxGenerator::Processor do

  let(:actor_pool) {mock}
  let(:workers) { TaxGenerator::FileCreator.new }

  before(:each) do

  end


  context "intialize" do

    specify { expect(subject.jobs).to eq({}) }
    specify { expect(subject.job_to_worker).to eq({}) }
    specify { expect(subject.worker_to_job).to eq({}) }
  end



  it 'returns the input folder' do
    subject.options.expects(:fetch).with(:input_dir, "#{root}/data/input")
    subject.input_folder
  end

  it 'returns the output_folder' do
    subject.options.expects(:fetch).with(:output_dir, "#{root}/data/output")
    subject.output_folder
  end

  it 'returns the taxonomy_filename' do
    subject.options.expects(:fetch).with(:taxonomy_filename, 'taxonomy.xml')
    subject.taxonomy_file_name
  end

  it 'returns the destinations_file_name' do
    subject.options.expects(:fetch).with(:destinations_filename, 'destinations.xml')
    subject.destinations_file_name
  end

  it 'returns the taxonomy_file_path' do
    File.expects(:join).with(subject.input_folder, subject.taxonomy_file_name).returns(true)
    subject.taxonomy_file_path
  end
  it 'returns the destinations_file_path' do
    File.expects(:join).with(subject.input_folder, subject.destinations_file_name).returns(true)
    subject.destinations_file_path
  end

  it 'returns the static_output_dir' do
    File.expects(:join).with(subject.output_folder, 'static').returns(true)
    subject.static_output_dir
  end


end
