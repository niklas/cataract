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

  describe '#find_directive' do
    it 'finds first directive matching the URI of the page [private]'
  end

  describe '#dig' do
    subject { described_class.new }
    let(:command) { double 'Commandable' }
    let(:page)    { double 'Page' }
    let(:directive) { double 'Directive', right: command }
    before :each do
      subject.stub find_directive: directive
    end

    describe 'with Command responding to #run' do
      it 'runs Command' do
        command.stub run: true
        command.should_receive :run
        subject.dig page
      end
    end

    describe 'with command being a symbol' do
      let(:command) { :fluppdiwupp }
      it 'calls own method with same name' do
        subject.should_receive(command)
        subject.dig page
      end
    end

    describe 'with list of commands' do
      let(:c1)      { double 'Command1' }
      let(:c2)      { double 'Command2' }
      let(:command) { [c1,c2] }
      it 'iterates through list as alternatives' do
        c1.should_receive :run
        c2.should_receive :call
        subject.dig page
      end
    end
    describe 'nothing of the above' do
      it 'treats it as callable' do
        command.should_receive(:call)
        subject.dig page
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

