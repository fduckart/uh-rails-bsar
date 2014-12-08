# Methods added to this helper will be available 
# to all templates in the application.
module ApplicationHelper
  
  class TaskType
    NEW_ACCOUNT    = 1
    REMOVE_ACCOUNT = 2
    RESET_PASSWORD = 3
    MODIFY_ACCOUNT = 6
  end
  
  class State
    COMPLETE = 'complete'
    NONE     = 'none'
    OPEN     = 'open'
  end
  
  ERRORS = {
    'empty_username' => 'You did not enter a UH Username.',
    'empty_state'    => 'The State is empty.',
    'empty_reason'   => 'You did not select a Reason.'
  }  
  
  class Strings
    def self.space_to_nbsp(string)
      begin
        result = string.gsub(' ', '&nbsp;')
      rescue Exception
        result = ''
      ensure
        if (result.nil?)
          result = ''
        end
      end
      return result
    end    
    
    def self.is_nil_or_empty(string)
      return string.nil? || string.strip.empty?
    end
  end
  
  class AccessMatrixLookup
    include Singleton
    
    def AccessMatrixLookup.find(user, controller)
      begin
        condition = %{role_id = #{user.role_id} AND 
                      controller = '#{controller.controller_name}' AND 
                      method = '#{controller.action_name}'}
        am = AccessMatrix.find(:first, :conditions => condition)
        if (am)
          return am.allowed
        end
      rescue Exception => ex
        puts ex
        logger.error(ex)
      end
      return false
    end
  end
  
end
