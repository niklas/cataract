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
