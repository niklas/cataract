require 'spec_helper'

describe SearchTorrentsOnline do

  context '#call' do
    subject { described_class.new filter: filter }
    let(:filter) { 'Shame of Frowns' }
    let(:ctx) { subject.context }

    it 'sets empty `torrents` when nothing was found' do
      subject.call
      ctx.should be_a_success

      ctx.torrents.should_not be_nil
      ctx.torrents.should be_an(Enumerable)
      ctx.torrents.should be_empty
    end

  end
end
