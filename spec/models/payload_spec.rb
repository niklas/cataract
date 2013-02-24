require 'spec_helper'

describe Torrent, 'payload' do
  let(:torrent) { create :torrent_with_picture_of_tails_and_a_poem }
  let(:payload) { torrent.payload }

  context "in filesystem" do
    let(:storage) { create :existing_directory, relative_path: 'storage' }
    let(:archive) { create :existing_directory, relative_path: 'archive' }

    describe "with single file" do
      let(:torrent) do
        create :torrent_with_picture_of_tails, content_directory: archive do |torrent|
          create_file storage.full_path/torrent.filename
          torrent
        end
      end

      it "knows the path of its torrent file" do
        torrent.path.should_not be_blank
        torrent.path.to_s.should be_ends_with('single.torrent')
      end
      it "knows the full path of its payload file" do
        payload.files.should == [
          archive.full_path/'tails.png'
        ]
      end
      it "knows the name of its payload file" do
        payload.relative_files.should == [
          'tails.png'
        ]
      end
      it "payload.path should point to file" do
        payload.path.should == archive.full_path/'tails.png'
      end

      it "can be destroyed" do
        expect { torrent.destroy }.to_not raise_error
      end
    end

    describe "with multiple files" do
      let(:torrent) do
        create :torrent_with_picture_of_tails_and_a_poem, content_directory: archive do |torrent|
          create_file storage.full_path/torrent.filename
          torrent
        end
      end
      it "knows the path of its torrent file" do
        torrent.path.should_not be_blank
        torrent.path.to_s.should be_ends_with('multiple.torrent')
      end
      it "knows the relative paths of its payload files" do
        payload.relative_files.should == [
          'content/banane.poem',
          'content/tails.png'
        ]
      end
      it "knows the names of its payload files" do
        payload.files.should == [
          archive.full_path/'content'/'banane.poem',
          archive.full_path/'content'/'tails.png'
        ]
      end
      it "payload.path should point to directory" do
        payload.path.should == archive.full_path/'content'
      end
    end

    describe "settings" do
      before { create :setting, incoming_directory: storage }
      it "should define content directory" do
        create(:torrent, content_directory: nil).content_directory.should == storage
      end
    end

  end

  context 'filenames' do
    subject { payload.relative_files }
    it "should be encoded in UTF8 spite being read binary from torrent" do
      subject.each do |filename|
        filename.encoding.should == Encoding::UTF_8
      end
    end
  end

end
