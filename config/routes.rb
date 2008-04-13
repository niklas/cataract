url_base_file = File.join(RAILS_ROOT,'config','urlbase.txt')
if File.exists? url_base_file
  url_base = File.read url_base_file
  url_base = "/#{url_base}" unless url_base =~ /^\//
  ActionController::AbstractRequest.relative_url_root = url_base
end

ActionController::Routing::Routes.draw do |map|
  map.resources :settings
  map.resources :torrents, 
    :member => { :start => :post, :stop => :post, :pause => :post, :fetch => :put},
    :collection => { :watched => :get, :search => :get } do |torrent|
    torrent.resource :files, :controller => 'torrents_files'
  end
  map.resources :watchings




  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  map.decoration 'decoration/:kind/:variant/:background_color', 
    :controller => 'lcars', :action => 'decoration',
    :defaults => { :background_color => 'black', :variant => 'se', :kind => 'bow' }

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  #map.login 'login', :controller => 'account', :action => 'login'
  map.connect 'stylesheets/:action.:format', :controller => 'stylesheets'
  map.connect 'torrents/list/:status', :controller => 'torrents', :action => 'list', :status => 'running'
  map.connect '', :controller => "torrents", :action => 'index'

  #Hobo.add_routes(map)
  map.connect 'javascripts/:action.:format', :controller => 'javascripts'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
