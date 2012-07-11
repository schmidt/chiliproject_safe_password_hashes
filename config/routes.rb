ActionController::Routing::Routes.draw do |map|

  map.with_options(:path_prefix => "safe_password_hashes",
                   :name_prefix => 'safe_password_hashes_') do |sph|
    sph.resource :password_security,
                 :only => "show",
                 :controller => "safe_password_hashes_password_security"
  end
end
