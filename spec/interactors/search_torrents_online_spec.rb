require 'spec_helper'

describe SearchTorrentsOnline do

  context '#call' do
    subject { described_class.new filter: filter }
    let(:filter) { 'Shame of Frowns' }
    let(:ctx) { subject.context }

    it 'sets empty `torrents` when nothing was found' do
      VCR.use_cassette 'kat-no-results' do
        subject.call
      end
      ctx.should be_a_success

      ctx.torrents.should_not be_nil
      ctx.torrents.should be_an(Enumerable)
      ctx.torrents.should be_empty
    end

    context 'without filter' do
      let(:filter) { nil }
      it 'fails' do
        expect { subject.call }.to raise_error(Interactor::Failure)
      end
    end

  end
end
