require File.dirname(__FILE__) + '/../test_helper'

class MyControllerTest < ActionController::TestCase
  # Avoid bugs based on Setting cache
  old_cache_value = nil

  setup do
    old_cache_value = Setting.use_caching?
    Setting.use_caching = false
  end

  teardown do
    Setting.use_caching = old_cache_value
  end

  context "with pbkdf2 password hash" do
    setup do
      Setting.plugin_safe_password_hashes = {
        "hash_function" => "pbkdf2_sha256",
        "iterations"    => "500",
        "key_length"    => "40"
      }

      @user = User.generate(:login => 'alfred', :password => 'bruce')
      @request.session[:user_id] = @user.id
    end

    should 'be able to change password without hash_function change' do
      post :password, :password => 'bruce',
                      :new_password => 'dick',
                      :new_password_confirmation => 'dick'

      @user.reload

      hash = PBKDF2.new(:hash_function => 'sha256',
                        :iterations    => 500,
                        :key_length    => 40,
                        :password      => 'dick',
                        :salt          => @user.salt).hex_string[0...40]

      assert_redirected_to :controller => 'my', :action => 'account'
      assert_equal User.current, @user
      assert_equal 'pbkdf2_sha256', @user.password_hash_function
      assert_equal hash, @user.hashed_password
    end

    context "after hash_work_load was changed" do
      setup do
        Setting.plugin_safe_password_hashes = {
          "hash_function" => "pbkdf2_sha256",
          "iterations"    => "100",
          "key_length"    => "40"
        }
      end

      should 'be able to change password with hash_function change' do
        post :password, :password => 'bruce',
                        :new_password => 'dick',
                        :new_password_confirmation => 'dick'

        @user.reload

        hash = PBKDF2.new(:hash_function => 'sha256',
                          :iterations    => 100,
                          :key_length    => 40,
                          :password      => 'dick',
                          :salt          => @user.salt).hex_string[0...40]

        assert_redirected_to :controller => 'my', :action => 'account'
        assert_equal User.current, @user
        assert_equal 'pbkdf2_sha256', @user.password_hash_function
        assert_equal hash, @user.hashed_password
      end
    end

    context "after hash_function was changed" do
      setup do
        Setting.plugin_safe_password_hashes = {
          "hash_function" => "pbkdf2_md5",
          "iterations"    => "500",
          "key_length"    => "40"
        }
      end

      should 'be able to change password with hash_function change' do
        post :password, :password => 'bruce',
                        :new_password => 'dick',
                        :new_password_confirmation => 'dick'

        @user.reload

        hash = PBKDF2.new(:hash_function => 'md5',
                          :iterations    => 500,
                          :key_length    => 40,
                          :password      => 'dick',
                          :salt          => @user.salt).hex_string[0...40]

        assert_redirected_to :controller => 'my', :action => 'account'
        assert_equal User.current, @user
        assert_equal 'pbkdf2_md5', @user.password_hash_function
        assert_equal hash, @user.hashed_password
      end
    end
  end

  context "with legacy password hash" do
    setup do
      Setting.plugin_safe_password_hashes = {
        "hash_function" => nil, # legacy
        "iterations"    => nil,
        "key_length"    => "40"
      }

      @user = User.generate(:login => 'alfred', :password => 'bruce')
      @request.session[:user_id] = @user.id
    end

    should 'be able to change password without hash_function change' do
      post :password, :password => 'bruce',
                      :new_password => 'dick',
                      :new_password_confirmation => 'dick'

      @user.reload

      assert_redirected_to :controller => 'my', :action => 'account'
      assert_equal User.current, @user
      assert_nil @user.password_hash_function
      assert_equal @user.hash_with_legacy('dick'), @user.hashed_password
    end

    context "after hash_function was changed" do
      setup do
        Setting.plugin_safe_password_hashes = {
          "hash_function" => "pbkdf2_sha256",
          "iterations"    => "500",
          "key_length"    => "40"
        }
      end

      should 'be able to change password with hash_function change' do
        post :password, :password => 'bruce',
                        :new_password => 'dick',
                        :new_password_confirmation => 'dick'

        @user.reload

        hash = PBKDF2.new(:hash_function => 'sha256',
                          :iterations    => 500,
                          :key_length    => 40,
                          :password      => 'dick',
                          :salt          => @user.salt).hex_string[0...40]

        assert_redirected_to :controller => 'my', :action => 'account'
        assert_equal User.current, @user
        assert_equal 'pbkdf2_sha256', @user.password_hash_function
        assert_equal hash, @user.hashed_password
      end
    end
  end
end
