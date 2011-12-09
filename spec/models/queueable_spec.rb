require 'spec_helper'

describe Queueable do
  it "should be a module" do
    described_class.should be_a(Module)
  end

  context "including" do
    let(:model) { Class.new(ActiveRecord::Base) }
    let(:including) { lambda { model.send(:include, described_class) } }

    it "should add scope: locked"
    it "should add class method wait_for_new_record" do
      pending
      should_receive(:listen!)
      should_receive(:unlisten!)
    end

  end
end
