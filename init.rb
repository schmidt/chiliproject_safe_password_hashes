require 'redmine'
require 'dispatcher'
require 'pbkdf2'

Dispatcher.to_prepare do
  require_dependency 'safe_password_hashes/patches/user_patch'
end

Redmine::Plugin.register :safe_password_hashes do
  name 'PBKDF2 for ChiliProject'
  author 'Gregor Schmidt'
  description "A plugin to improve the security of your user's passwords"
  version '0.0.1'

  settings :default => HashWithIndifferentAccess.new(
    'hash_function' => 'pbkdf2_sha256', # Default in PBKDF2-ruby
    'iterations'    => '5_000', # Recommendation in PBKDF2-ruby's README

    # TODO: Check if we can support changing this value. Currently it
    # is just a setting to avoid magic numbers. Might be, that that's
    # not the best solution.
    #
    # Another option would be : User.columns_hash['hashed_password'].limit
    'key_length'    => '40'    # Length of DB field in ChiliProject 3.x
  )

  menu :admin_menu, :safe_password_hashes_password_security,
                    {:controller => "safe_password_hashes_password_security",
                     :action     => "show"},
                    :caption => :"safe_password_hashes.password_security"
end
