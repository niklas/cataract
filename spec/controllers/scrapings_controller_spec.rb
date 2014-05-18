require 'spec_helper'

describe ScrapingsController do
  signin_user
  describe '#new' do
    it 'allows to displayed in an iframe' do
      get :new, url: 'http://somewhere.com'
      response.should be_success
      if frameopts = response.headers['X-Frame-Options']
        frameopts.should_not include('SAMEORIGIN')
      end
    end
  end
end
