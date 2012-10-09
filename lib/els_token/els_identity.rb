module ElsToken
  
  
  
  class ElsIdentity
    attr_reader :roles, :mail, :last_name, :first_name, :uac, :dn, :common_name
    attr_reader :employee_number, :display_name, :name, :token_id, :user_status

    alias :cdid :name
    
    # The Active Directory User Account Control contains lots of
    # interesting info about the user account state. This method
    # does a very simple check to see if the account is enabled
    # and return either "enabled" or "disabled". There are many
    # other states but I don't use them
    def friendly_uac
      @friendly_uac ||= (@uac.to_i & 2 == 0) ? "enabled" : "disabled"
    end
    
    def has_role?(role)
      @roles.include? role
    end

    def initialize(rest_response = nil)
      @roles = []
      parse(rest_response) if rest_response
      @lines = nil
    end

    private


      def parse(response)
        @lines = response.lines
        begin
          while @lines.peek
            line = @lines.next.chomp
            case
              when line =~ /userdetails\.role/
                @roles    << line.split(",")[0].sub(/^userdetails\.role=id=/,"")

              when line =~ /userdetails\.token\.id/
                @token_id = line.sub(/userdetails\.token\.id=/,"")

              when line =~ /name=mail/
                self_set :mail

              when line =~ /attribute\.name=sn/
                self_set :last_name

              when line =~ /name=useraccountcontrol/
                self_set :uac

              when line =~ /name=givenname/
                self_set :first_name

              when line =~ /name=distinguishedname/
                self_set :dn

              when line =~ /name=employeenumber/
                self_set :employee_number

              when line =~ /name=cn/
                self_set :common_name

              when line =~ /name=name/
                self_set :name

              when line =~ /name=displayname/
                self_set :display_name
                
              when line =~ /name=inetUserStatus/
                self_set :user_status
            end
          end
        rescue 
          # nadda
        end
      end

      USER_ATTRIB_VALUE = /^userdetails\.attribute\.value=/

      def self_set(v)
        self.instance_variable_set("@#{v.to_s}",
          @lines.next.chomp.sub(USER_ATTRIB_VALUE,""))
      end

  end
  
end