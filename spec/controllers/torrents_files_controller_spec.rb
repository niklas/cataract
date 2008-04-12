require File.dirname(__FILE__) + '/../spec_helper'

describe TorrentsFilesController do

  #Delete these examples and add some real ones
  it "should use TorrentsFilesController" do
    controller.should be_an_instance_of(TorrentsFilesController)
  end


  it "GET 'show' should be successful" do
    get 'show'
    response.should be_success
  end

  it "GET 'update' should be successful" do
    get 'update'
    response.should be_success
  end
end
