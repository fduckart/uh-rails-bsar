class ApplicationControllerTest < ActionController::TestCase
  
  def setup()
    authenticator = LoginHelper::AuthenticatorTestProxy.new
    @controller = ApplicationController.new(authenticator)
  end
  
  def test_get_current_username()
    cas_response_body = "duckart\n17958670\nFrank R Duckart\nstaff\nuhsystem\n"  
    cas_response_body += "eduPersonOrgDn=uhsystem,eduPersonAffiliation=staff"
    @controller.session = ActionController::TestSession.new({:cas_user => cas_response_body})    
    user_name = @controller.get_current_username
    assert_equal "duckart", user_name
    
    cas_response_body = "duckart\r17958670"  
    @controller.session = ActionController::TestSession.new({:cas_user => cas_response_body})
    user_name = @controller.get_current_username
    assert_equal "duckart", user_name
          
    cas_response_body = "duckart\n\r17958670\nFrank R Duckart"  
    @controller.session = ActionController::TestSession.new({:cas_user => cas_response_body})
    user_name = @controller.get_current_username
    assert_equal "duckart", user_name
    
    cas_response_body = "duckart\n\n17958670\nFrank R Duckart"  
    @controller.session = ActionController::TestSession.new({:cas_user => cas_response_body})
    user_name = @controller.get_current_username
    assert_equal "duckart", user_name
    
    cas_response_body = "duckart\n\r\n17958670\nFrank R Duckart"  
    @controller.session = ActionController::TestSession.new({:cas_user => cas_response_body})
    user_name = @controller.get_current_username
    assert_equal "duckart", user_name
    
    cas_response_body = "duckart\f17958670\nFrank R Duckart"  
    @controller.session = ActionController::TestSession.new({:cas_user => cas_response_body})
    user_name = @controller.get_current_username
    assert_equal "duckart\f17958670", user_name
    
    cas_response_body = "duckart 17958670\nFrank R Duckart"  
    @controller.session = ActionController::TestSession.new({:cas_user => cas_response_body})
    user_name = @controller.get_current_username
    assert_equal "duckart 17958670", user_name
  end
  
end