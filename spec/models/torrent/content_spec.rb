require 'spec_helper'

describe Torrent, 'content' do
  let(:torrent) { create :torrent_with_picture_of_tails_and_a_poem }

  context 'filenames' do
    subject { torrent.content.relative_files }
    it "should be encoded in UTF8 spite being read binary from torrent" do
      subject.each do |filename|
        filename.encoding.should == Encoding::UTF_8
      end
    end
  end
end
