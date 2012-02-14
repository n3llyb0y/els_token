class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include ElsToken
  els_faker "neilcuk","development","test"
  els_base_uri "https://elsuat-admin.corp.aol.com:443/opensso/identity/authenticate"
  
  before_filter :authenticate
  

  private
  
  def authenticate
    session[:user_cdid] ||= get_els_token
    unless session[:user_cdid]
      render :nothing => true, :status => :unauthorized
    end
    @authenticated = els_authenticated?(@username,@password)
  end

end
