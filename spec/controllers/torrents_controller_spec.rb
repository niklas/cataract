require 'spec_helper'

describe TorrentsController do
  signin_user

  describe '#index JSON' do
    it "succeeds with at least one torrent" do
      create :torrent
      get :index, format: 'json'
      response.should be_success
    end
  end

  describe '#create JSON' do
    it "sets flash for ember on fail" do
      post :create, torrent: { filename: "mom.jpg", filedata: "data:image/jpeg;base64,/9j57vM//9k=", start_automatically: true}, format: 'json'
      response.code.should == "422"
      flash[:alert].should_not be_blank
    end
  end
end
