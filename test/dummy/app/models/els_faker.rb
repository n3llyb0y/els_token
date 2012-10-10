# Simple class Used for development only
class ElsFaker < ElsToken::ElsIdentity
  def initialize(cdid)
    super
    @name = cdid
    @token_id = Random.rand
  end 
end