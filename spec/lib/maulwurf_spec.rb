require 'maulwurf'

describe Maulwurf do

  let(:klass) { Class.new(Maulwurf) }

      #expr = double 'Expr'
  describe 'setup' do
    it 'accepts follow directive' do
      link = double 'Link'
      klass.follow link
    end
  end

end
