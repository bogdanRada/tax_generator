# encoding:utf-8
require 'spec_helper'
describe TaxGenerator::Processor do

  let(:actor_pool) {mock}
  let(:workers) { TaxGenerator::FileCreator.new }

  before(:each) do
      Celluloid::SupervisionGroup.stubs(:run!).returns(actor_pool)
      actor_pool.stubs(:pool).returns(workers)
      Actor.current.stubs(:link).returns(true)
  end

  context "intialize" do

    it 'boots the celluloid' do
      Celluloid.expects(:boot).returns(true)
      TaxGenerator::Processor.new
    end

    it 'runs the supervision group' do
      Celluloid::SupervisionGroup.expects(:run!).returns(actor_pool)
      TaxGenerator::Processor.new
    end

    it 'creates the pool of workers' do
      actor_pool.expects(:pool).with(TaxGenerator::FileCreator, as: :workers, size: 50).returns(workers)
      TaxGenerator::Processor.new
    end


    it "links the actor to the current actor" do
      Actor.current.expects(:link).with(workers)
      TaxGenerator::Processor.new
    end


  end

  context "intialize" do
    let(:subject) {TaxGenerator::Processor.new}



  end


end
