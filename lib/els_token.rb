require 'els_token/module_inheritable_attributes'
require 'els_token/els_user'
require 'net/http'
require 'uri'

module ElsToken
    
  def self.included(base)
    base.extend ClassMethods
    base.send :include, ElsToken::ModuleInheritableAttributes
    base.send :mattr_inheritable, :els_options
    base.instance_variable_set("@els_options", {})
  end

  module ClassMethods
    
    # els_config expects a nice hash telling
    # it if it will have a fake user (handy for dev)
    # and the url of the openAM REST API.
    # { faker => { user => 'username',
    #             :environments => ['dev','test'] },
    #   uri => 'https://openam.url' }
    #
    #   class MyController
    #     include ElsToken
    #     els_config options_hash
    #   end
    def els_config(options = {})
      @els_options = options
    end
  
  end

  # authenticates against ELS and returns the user token
  def authenticate(username,password)

    begin
      response = els_http_request("/authenticate","uri=realm=aolcorporate&username=#{username}&password=#{password}")
      if response.code.eql? "200"
        # return the token
        response.body.chomp.sub(/token\.id=/,"")
      else
        raise response.error! 
      end
    rescue Net::HTTPExceptions => e1
      raise e1, "token retrieval failed for #{username}"
    rescue Exception => e
      # Do not expect these. Wrapping the exception so
      # as to not reveal the passed in password
      raise e, "unable to fetch token for #{username}"
    end
  end
  
  def is_token_valid?(token)
    response = els_http_request("/isTokenValid","tokenid=#{token}")
    if response.code.eql? "200"
      true
    else
      false
    end
  end

  #extract the token from the rack cookie
  def is_cookie_token_valid?
    return true if fake_it?
    token = cookies[self.class.els_options['cookie']]
    if token.nil? || !is_token_valid?(token)
      false
    else
      true
    end
  end

  # obtain a full ElsIdentity object
  def get_token_identity(token)
    response = els_http_request("/attributes","subjectid=#{token}")
    if response.code.eql? "200"
      ElsIdentity.new(response.body)
    else
      response.error!
    end
  end
  
  # When used inside a rack environment
  # will attempt to retrieve the user token
  # from the session cookie and return a full
  # identity
  def get_identity
    return fake_id if fake_it?
    begin
      if is_cookie_token_valid?
        get_token_identity cookies[self.class.els_options['cookie']]
      else
        raise "token is invalid"
      end
    rescue Exception => e
      raise e
    end
  end 
      
  def method_missing(m, *args, &block)
    puts "Drop the crack pipe - There is no method called #{m}"
  end

  private
  
  def els_http_request(url_base_extension, query_string)
    uri = URI.parse(self.class.els_options['uri'] + url_base_extension)
    uri.query=query_string
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true
    
    # Use a known certificate if supplied
    if rootca = self.class.els_options[:cert]
      if File.exist? rootca
        http.ca_file = rootca
      elsif Dir.exist? rootca
        http.ca.path = rootca
      else
        raise "${rootca} cannot be found"
      end
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.verify_depth = 5
    else
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    request = Net::HTTP::Get.new(uri.request_uri)

    http.request(request)
  end
  
  def fake_it?
    self.class.els_options.has_key? 'faker'
  end

  def fake_id
    unless @fake_id
      id = ElsIdentity.new
      id.instance_variable_set("@roles",self.class.els_options['faker']['roles'])
      id.instance_variable_set("@mail",self.class.els_options['faker']['mail'])
      id.instance_variable_set("@last_name",self.class.els_options['faker']['last_name'])
      id.instance_variable_set("@first_name",self.class.els_options['faker']['first_name'])
      id.instance_variable_set("@uac",self.class.els_options['faker']['uac'])
      id.instance_variable_set("@dn",self.class.els_options['faker']['dn'])
      id.instance_variable_set("@common_name",self.class.els_options['faker']['common_name'])
      id.instance_variable_set("@employee_number",self.class.els_options['faker']['employee_number'])
      id.instance_variable_set("@display_name",self.class.els_options['faker']['display_name'])
      id.instance_variable_set("@token_id",self.class.els_options['faker']['token_id'])
      @fake_id = id
    end
    @fake_id
  end

end
