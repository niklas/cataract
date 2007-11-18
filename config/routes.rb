ActionController::Routing::Routes.draw do |map|


  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  #map.login 'login', :controller => 'account', :action => 'login'
  map.connect 'stylesheets/:action.:format', :controller => 'stylesheets'
  map.connect 'torrents/list/:status', :controller => 'torrents', :action => 'list', :status => 'running'
  map.connect '', :controller => "torrents", :action => 'list'

  #Hobo.add_routes(map)

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
