require 'spec_helper'

describe Torrent do
  let(:file_path) { Rails.root/'spec'/'factories'/'files'/'single.torrent' } 

  describe "with multipart uploaded file" do
    let(:torrent) { Torrent.create! file: File.open(file_path)}

    it "knows the file exists" do
      torrent.should be_file_exists
    end

    it "should have file name set" do
      torrent.filename.should == 'single.torrent'
    end

    it "should have info hash set" do
      torrent.info_hash.should =~ /^[0-9A-Z]{40}$/
    end
  end

  describe "with json-uploaded file" do
    let(:binary)  { File.read(file_path) }
    let(:torrent) { Torrent.new(filedata: base64, filename: "s.torrent" ) }

    # this is what HTML5 FileReader.readAsDataURL returns
    let(:base64) { "data:application/x-bittorrent;base64,ZDg6YW5ub3VuY2UzMDpodHRwOi8vMTI3LjAuMC4xOjY5NjkvYW5ub3VuY2UxMzpjcmVhdGlvbiBkYXRlaTEzMjM1NjQxNThlNDppbmZvZDY6bGVuZ3RoaTczNDUxZTQ6bmFtZTk6dGFpbHMucG5nMTI6cGllY2UgbGVuZ3RoaTI2MjE0NGU2OnBpZWNlczIwOr6kcgJtGGgwiVM9tKl37H+YOaALZWU=" }

    it "should use correct base64 data" do
      Base64.strict_encode64(torrent.filedata).should == Base64.strict_encode64(binary)
    end

    it "should be valid" do
      torrent.should be_valid
    end

    it "should set the file" do
      torrent.valid?
      torrent.file.should_not be_blank
    end

    describe 'saved' do
      before :each do
        torrent.save!
      end

      it "should be able to read the data" do
        torrent.payload.filenames.should include("tails.png")
      end
    end

  end
end

