require 'spec_helper'

describe Torrent, "with uploaded file" do
  let(:file_path) { Rails.root/'spec'/'factories'/'files'/'single.torrent' } 
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
