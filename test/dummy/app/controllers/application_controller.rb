class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include ElsToken
  els_config ELS_CONFIG
  
  before_filter :els_identity
  
  private
  
  def els_identity
    # test for override first
    if session[:els_override]
      @els_identity = session[:els_override]
    else
      begin
        if session[:els_token]
          @els_identity ||= get_identity
        else
          session[:redirect_to] = request.env["PATH_INFO"]
          logger.debug("user will be returned to #{session[:redirect_to]}")
          redirect_to els_session_new_path
        end
      rescue Exception => e
        logger.warn(e)
        redirect_to els_session_new_path
      end
    end
  end


end
