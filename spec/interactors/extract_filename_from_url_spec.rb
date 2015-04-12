require 'spec_helper'

describe ExtractFilenameFromURL do
  subject { described_class.new url: url }
  let(:ctx) { subject.context }
  let(:url) { nil }
  let(:fn) { ctx.filename }

  context 'given nil url' do
    it 'fails' do
      expect { subject.call }.to raise_error
      ctx.should be_a_failure
    end
  end

  context 'given url from RSS feed' do
    let(:url) { 'http://torcache.net/torrent/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB.torrent?title=[kickass.to]something.720p.hdtv.x264.mvgroup.org' }

    it 'extracts filename from query param (and adds ext)' do
      subject.call
      ctx.should be_a_success
      fn.should == '[kickass.to]something.720p.hdtv.x264.mvgroup.org.torrent'
    end
  end

  context 'given an url ending in filename with proper ext' do
    let(:url) { 'http://hashcache.net/files/something.torrent' }

    it 'extracts filename from base of url' do
      subject.call
      ctx.should be_a_success
      fn.should == 'something.torrent'
    end
  end

  context 'given an url ending in filename without proper ext' do
    let(:url) { 'http://hashcache.net/files/something' }

    it 'extracts filename from base of url and adds ext' do
      subject.call
      ctx.should be_a_success
      fn.should == 'something.torrent'
    end
  end

end
