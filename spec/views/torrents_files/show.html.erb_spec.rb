require File.dirname(__FILE__) + '/../../spec_helper'

describe "/torrents_files/show" do
  before do
    render 'torrents_files/show'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', /Find me in app\/views\/torrents_files\/show/)
  end
end
