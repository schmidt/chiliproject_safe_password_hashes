require_dependency 'principal'
require_dependency 'user'

module Pbkdf2Chiliproject::Patches::UserPatch
  def self.included(base)
    base.class_eval do
      unloadable

      include InstanceMethods
      extend ClassMethods

      alias_method_chain :check_password?, :pbkdf2
      alias_method_chain :salt_password,   :pbkdf2
    end
  end

  module InstanceMethods
    def check_password_with_pbkdf2?(plain_text_password)
      logger.info 'checking with peanut butter'
      check_password_without_pbkdf2?(plain_text_password)
    end

    def salt_password_with_pbkdf2(plain_text_password)
      logger.info 'salting with peanut butter'
      salt_password_without_pbkdf2(plain_text_password)
    end
  end

  module ClassMethods
    def salt_unsalted_passwords_with_pbkdf2!
    end
  end
end

User.send(:include, Pbkdf2Chiliproject::Patches::UserPatch)
