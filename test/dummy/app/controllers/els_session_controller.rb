class ElsSessionController < ApplicationController

  skip_before_filter :els_identity, :except => [:show]

  def show
  end

  # When in dev/qa we may need to provide credentials
  # if ELS has not been setup
  def new
    @els_identity = get_identity rescue nil
    if @els_identity
      update_and_return
    end
  end

  # Should not get here during production
  def create
    logger.debug(params.inspect)
    begin
      if params["override"]
        # just fake the session
        @els_identity = session[:els_override] = ElsFaker.new(params["username"])
      else
        token = authenticate(params["username"],params["password"])
        logger.debug("got token #{token}")
        if token
          @els_identity = get_token_identity(token)
          flash[:notice] = "cannot retrieve identity" unless @els_identity
        else
          flash[:error] = "unable to authenticate"
        end
      end
    rescue Exception => e
      flash[:error] = "Something went wrong #{e.message}"
    end
    if @els_identity
      update_and_return
    else
      render :new
    end
  end

  def destroy
    session[:cdid] = nil
    session[:els_identity] = nil
    cookies.delete(ELS_CONFIG['cookie'], :domain => request.env["SERVER_NAME"])
    redirect_to els_session_new_path
  end

  private

  # This app should really be running behind an els processor
  # stashing the els token against the current host should allow
  # for a better dev/qa experience without affecting production
  def stash_cookie
    cookies[ELS_CONFIG['cookie']] = {
      :value => @els_identity.token_id,
      :domain => request.env["SERVER_NAME"],
      :path => '/',
      :expires => Time.now + 24.hours
    }
  end

  def update_and_return
    stash_cookie
    session[:els_token] = @els_identity.token_id
    session[:cdid] = @els_identity.cdid
    if session[:redirect_to] =~ /session\//
      # Do not redirect back to a session action
      redirect_to root_path
    else
      redirect_to session[:redirect_to]
    end 
  end
  
  class ElsFaker 
    attr_accessor :cdid, :token_id
    def initialize(cdid)
      @cdid = cdid
      @token_id = Random.rand
    end 
  end

end