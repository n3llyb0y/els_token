class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include ElsToken
  els_config ELS_CONFIG
  
  helper_method :remote_user, :rpa_username, :els_identity
  
  private
  
  # will set a @cdid instance variable
  # determined by the REMOTE_USER or RPA_USERNAME headers.
  # cdid doesn't change often so it's gets stashed in the session  
  #
  def cdid
    @cdid ||= 
    session[:cdid] ||= 
    request.headers["REMOTE_USER"] ||=
    request.headers["RPA_USERNAME"]
  end
  
  # the els_identity is backed by the ELS SSO system.
  # It will try to get a full identity object and then store
  # that in a memcache as raw retrieval currently hits performance.
  # Whilst SSO is brilliant, it can be a bit of a drag working around
  # it during development.
  # 
  # This method will allow an end user to circumvent
  # the domain specific ELS login by authenticating directly with the ELS
  # system or, if a cookie is already resent, use that to retrieve an identity.
  # As an additional development bonus, it's possible to fake the identity -
  # setting it to whatever username is desired. 
  #
  # It's up to the implementer to test the validity of that username in 
  # their own application. 
  # Likewise once you have an ElsIdentity object you may want to call your own
  # usermodel based on some value. 'cdid' and 'employee_number'
  # are common ones.
  #
  # One of the best things about the ElsIdentity is that it contains Group
  # information :) So, rather than implementing yet-another-role system in
  # your app, let the identity be managed centrally. Once you have the
  # ElsIdentity you can ask it whether it belongs to some role:
  #
  #  @els_identity.has_role? "some group"
  # 
  def els_identity
    @els_identity = Rails.cache.fetch(session[:els_token], :namespace => "els_identity")
    unless @els_identity
      Rails.logger.debug("no identity in cache. Redirecting")
      session[:redirect_to] = request.env["PATH_INFO"]
      logger.debug("user will be returned to #{session[:redirect_to]}")
      redirect_to els_session_new_path
    end
  end

end
