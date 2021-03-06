require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'

module SafePasswordHashes::Patches::UserPatch
  def self.included(base)
    base.class_eval do
      unloadable

      include InstanceMethods
      extend ClassMethods

      alias_method_chain :check_password?, :safe_password_hashes
      alias_method_chain :salt_password,   :safe_password_hashes
    end
  end

  module InstanceMethods
    # alias chained core method
    #
    # Used for authentication whenever somebody tries to log in
    def check_password_with_safe_password_hashes?(plain_text_password)
      if auth_source_id.present?
        auth_source.authenticate(self.login, plain_text_password)
      else
        result = hashed_password == hash_with_user_settings(plain_text_password)

        # protection against timing attacks
        sleep(rand / 10) if result == false

        result
      end
    end

    # alias chained core method
    #
    # Used to calculate hashed_password, whenever somebody changes his passwords
    def salt_password_with_safe_password_hashes(plain_text_password)
      self.salt = User.generate_salt
      self.password_hash_function  = Setting.plugin_safe_password_hashes["hash_function"]
      self.password_hash_work_load = Setting.plugin_safe_password_hashes["iterations"].to_i

      self.hashed_password = hash_with_user_settings(plain_text_password)
    end

    def hash_with_user_settings(plain_text_password)
      case password_hash_function
      when /^pbkdf2/
        hash_with_pbkdf2(plain_text_password)

      when nil
        hash_with_legacy(plain_text_password)

      else
        raise "Unknown password_hash_function: #{password_hash_function.inspect}"
      end
    end

    # This method was used since ChiliProject 2.0
    def hash_with_legacy(plain_text_password)
      User.hash_password("#{salt}#{User.hash_password plain_text_password}")
    end

    def hash_with_pbkdf2(plain_text_password)
      actual_hash_function = self.password_hash_function.sub(/^pbkdf2_/, '')
      key_length = Setting.plugin_safe_password_hashes['key_length'].to_i

      PBKDF2.new(
        :hash_function => actual_hash_function,

        # TODO: Make sure, that these values are not 0 - which would happen, if
        # somebody stored arbitrary String values
        :iterations  => self.password_hash_work_load,
        :key_length  => key_length,

        :password    => plain_text_password,
        :salt        => self.salt
      ).hex_string[0...key_length]
    end
  end

  module ClassMethods
    def salt_unsalted_passwords_with_safe_password_hashes!
    end
  end
end

User.send(:include, SafePasswordHashes::Patches::UserPatch)
