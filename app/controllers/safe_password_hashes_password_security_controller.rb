class SafePasswordHashesPasswordSecurityController < ApplicationController
  unloadable
  before_filter :require_admin
  layout 'admin'

  def show
  end
end
