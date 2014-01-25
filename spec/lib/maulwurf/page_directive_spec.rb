require 'maulwurf'

describe Maulwurf::PageDirective do

  describe '#responsible_for?' do
    subject { described_class.new %r~http://cats.in.baskets~ => double }

    it 'knows when it is responsible' do
      should be_responsible_for 'http://cats.in.baskets/XYZ'
    end
    it 'knows when it is not responsible' do
      should_not be_responsible_for 'dogs.in.baskets/ABC'
    end
  end

end
