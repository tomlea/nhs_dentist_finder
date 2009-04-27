ActionController::Routing::Routes.draw do |map|
  map.connect 'stylesheets/:stylesheet.css', :controller => "dynamic_sass/stylesheets", :action => "show", :only => :get
end
