require 'redmine'
require 'dispatcher'
require 'pbkdf2'

Dispatcher.to_prepare do
  require_dependency 'pbkdf2_chiliproject/patches/user_patch'
end

Redmine::Plugin.register :pbkdf2_chiliproject do
  name 'PBKDF2 for ChiliProject'
  author 'Gregor Schmidt'
  description "A plugin to improve the security of your user's passwords"
  version '0.0.1'

  # Those settings are not meant to be changed after this plugin was installed
  settings :hash_function => 'sha256', :iterations => '5000'
end
