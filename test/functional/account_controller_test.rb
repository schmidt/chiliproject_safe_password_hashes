require File.dirname(__FILE__) + '/../test_helper'

class AccountControllerTest < ActionController::TestCase
  # Avoid bugs based on Setting cache
  old_cache_value = nil

  setup do
    old_cache_value = Setting.use_caching?
    Setting.use_caching = false
  end

  teardown do
    Setting.use_caching = old_cache_value
  end

  context "with legacy password" do
    setup do
      Setting.plugin_safe_password_hashes = {
        "hash_function" => nil, # legacy
        "iterations"    => nil,
        "key_length"    => "40"
      }

      @user = User.generate(:login => 'alfred', :password => 'bruce')
    end

    should 'be able to log in with proper credentials' do
      post :login, :username => 'alfred', :password => 'bruce'
      assert_redirected_to :controller => 'my', :action => 'page'
      assert_equal User.current, @user
    end

    should 'not be able to log in with wrong credentials' do
      post :login, :username => 'alfred', :password => 'wayne'
      assert_response :success
      assert User.current.anonymous?
    end

    context "after hash_function was changed" do
      setup do
        Setting.plugin_safe_password_hashes = {
          "hash_function" => "pbkdf2_sha256",
          "iterations"    => "500",
          "key_length"    => "40"
        }
      end

      should 'be able to log in with proper credentials' do
        post :login, :username => 'alfred', :password => 'bruce'
        assert_redirected_to :controller => 'my', :action => 'page'
        assert_equal User.current, @user
      end

      should 'not be able to log in with wrong credentials' do
        post :login, :username => 'alfred', :password => 'wayne'
        assert_response :success
        assert User.current.anonymous?
      end
    end
  end
end
