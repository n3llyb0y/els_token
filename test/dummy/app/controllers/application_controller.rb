class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include ElsToken
  els_config ELS_CONFIG
  
  before_filter :authenticate
  
  private
  
  def authenticate
    @current_user ||= session[:user] ||= get_identity
    unless session[:user]
      render :nothing => true, :status => :unauthorized
    end
  end

end
