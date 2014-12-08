module LoginHelper
  
  class AuthenticatorBase
    attr_accessor :controller    
  end
  
  class Authenticator < AuthenticatorBase
    def authenticate_user    
      begin
        CASClient::Frameworks::Rails::Filter.filter(@controller)
      rescue Exception => ex
        puts ex
        raise ex
      end
    end
   end
 
  class AuthenticatorTestProxy < AuthenticatorBase
    def authenticate_user 
      authorize()
    end    
        
    def authorize
      session = @controller.session
      user = User.find_by_username(session[:cas_user])
      unless user
        request = @controller.request
        session[:original_uri] = request.request_uri 
        session[:cas_user] = nil
        @controller.response.flash[:notice] = "Please log in..."
        uri = '/login?service=' 
        uri += CGI::escape(ENV['CAS_BAS_URL'] + request.request_uri.to_s)
        @controller.redirect_to_ex uri
      end
    end
    
  end
end
