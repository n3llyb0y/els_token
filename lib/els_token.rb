require 'els_token/module_inheritable_attributes'
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
    
    # Allows setting a fake user id
    # for a given environment
    # 
    #   class MyController
    #     include ElsToken
    #     els_faker "userid", :development, :test
    #   end
    def els_faker(user,*environments)
      els_options[:faker] = {
        :user => user,
        :environments => environments
      }
    end

    # Allows setting the base uri of the els
    # REST interface for interactive authentication
    #
    #   class MyController
    #     include ElsToken
    #     els_base_uri "http://openam.rest.interface"
    #   end
    def els_base_uri(uri)
      els_options[:uri] = uri
    end

  end

  # Retrives the els token in the form
  # of a user cdid.
  def get_els_token
    Rails.logger.debug("els token called by #{self}")
    if fake_it?
      @cdid = self.class.els_options[:faker][:user]
    else
      @cdid = request.headers["REMOTE_USER"]
    end
    @cdid
  end

  def els_authenticated?(username, password)
    return true if fake_it?
    
    uri = URI.parse(self.class.els_options[:uri])
    uri.query="username=#{username}&password=#{password}"
    
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true
    # introduce a certificte chain to avoid this
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    response.code == "200"
  end

  private

  def fake_it?
    self.class.els_options[:faker] &&
    self.class.els_options[:faker][:environments].include?(Rails.env.to_sym)
  end

end
