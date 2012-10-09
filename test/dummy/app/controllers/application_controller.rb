class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include ElsToken
  els_config ELS_CONFIG
  
  before_filter :els_identity
  
  private
  
  def els_identity
    begin
      if session["els_token"]
        @els_identity ||= get_identity
      else
        session[:redirect_to] = request.env["PATH_INFO"]
        logger.debug("user will be returned to #{session[:redirect_to]}")
        redirect_to session_new_path
      end
    rescue Exception => e
      logger.warn(e)
      redirect_to session_new_path
    end
  end


end
