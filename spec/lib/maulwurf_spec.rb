require 'maulwurf'

describe Maulwurf do

  let(:klass) { Class.new(Maulwurf) }

      #expr = double 'Expr'
  describe 'setup' do
    describe '.follow' do
      it 'defines follow command' do
        link = double 'Link'
        com = klass.follow link
        com.should_not be_nil
      end
    end

    describe '.page' do
      it 'creates one more directive' do
        expect {
          klass.page x: 3
        }.to change { klass.directives.length }.from(0).to(1)
      end
    end
  end
end

describe Maulwurf::Directive do
  describe 'with left: ABC' do
    subject { described_class.new(/ABC/ => nil) }
    it 'is responsible for ABC' do
      should be_responsible_for('ABC')
    end

    it 'is not responsible for BCA' do
      should_not be_responsible_for('BCA')
    end
  end
end

