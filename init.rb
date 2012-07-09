require 'redmine'
require 'dispatcher'
require 'pbkdf2'

Dispatcher.to_prepare do
  require_dependency 'chiliproject_pbkdf2/patches/user_patch'
end

Redmine::Plugin.register :chiliproject_pbkdf2 do
  name 'PBKDF2 for ChiliProject'
  author 'Gregor Schmidt'
  description "A plugin to improve the security of your user's passwords"
  version '0.0.1'

  settings :default => HashWithIndifferentAccess.new(
    'hash_function' => 'pbkdf2_sha256', # Default in PBKDF2-ruby
    'iterations'    => '5000', # Recommendation in PBKDF2-ruby's README

    # TODO: Check if we can support changing this value. Currently it
    # is just a setting to avoid magic numbers. Might be, that that's
    # not the best solution.
    'key_length'    => '40'    # Length of DB field in ChiliProject 3.x
  )
end
