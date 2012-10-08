require 'els_token/module_inheritable_attributes'
require 'els_token/els_identity'
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
    
    # els_config expects a hash with environmental
    # parameters including the els gateway and expected
    # cookie name (when used in a Rack environment)
    # An optional fake identity can be supplied which
    # will override any active authentication. This can
    # be especially useful during automated testing.
    # The fake ID can take any of the ElsIdentity properties
    #
    # A typical setup would initialize a options hash to
    # include the following
    #
    #  faker:
    #    name: neilcuk
    #    employee_number: 09095
    #    roles:
    #      - App Admins
    #      - Domain Users
    #  uri: https://els-admin.corp.aol.com:443/opensso/identity
    #  cookie: iPlanetDirectoryPro
    #  cert: /path/to/certs
    #
    # Do not include the faker object in your production
    # configuration :)
    #
    # only the uri option is required if you are not worried
    # about cookies and do not plan on using them. If you want
    # to include a certificate for interacting with the ELS
    # server then you can specify a file or directory to find
    # the cert. By default Certificate validiation is off!
    #
    def els_config(options = {})
      unless options["uri"]
        raise "I need a uri to authenticate against" unless options["faker"]
      end
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
  
  # passes a token to els to see if it is still valid
  def is_token_valid?(token)
    response = els_http_request("/isTokenValid","tokenid=#{token}")
    if response.code.eql? "200"
      true
    else
      false
    end
  end

  # extract the token from a cookie
  # This method expects a hash called cookies
  # to be present. It will look for a cookie with
  # the key of the cookie value in the config hash
  def is_cookie_token_valid?
    return true if fake_it?
    raise "No cookies instance found" if cookies.nil?
    token = cookies[self.class.els_options['cookie']]
    if token.nil? || !is_token_valid?(token)
      false
    else
      true
    end
  end

  # obtain a friendly ElsIdentity object by passing
  # in a token
  def get_token_identity(token)
    ElsIdentity.new(get_raw_token_identity(token))
  end
  
  # get_token_identity wraps the ELS identity response
  # in a nice, friendly, object. If you don't like that object
  # or need the raw data, then use this.
  def get_raw_token_identity(token)
    response = els_http_request("/attributes","subjectid=#{token}")
    if response.code.eql? "200"
      response.body
    else
      response.error!
    end
  end
  
  # When used inside a rack environment
  # will attempt to retrieve the user token
  # from the session cookie and return a full
  # identity. This is pretty much a convenience
  # method that chains is_cookie_token_valid?
  # then get_token_identity
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
      id.instance_variable_set("@user_status",self.class.els_options['faker']['user_status'])
      @fake_id = id
    end
    @fake_id
  end

end
