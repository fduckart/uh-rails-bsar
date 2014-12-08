module ControllerActions
  APPROVER_LOGIN        = %w{add_user delete_user index login login_user
                             lookup_user list_users}
  APPROVER_TERMINATE    = %w{closed edit new open search}
  APPROVER_TICKET       = %w{add edit index open new}
  
  BANNERITE_LOGIN       = %w{index login login_user}
  
  COORDINATOR_LOGIN     = %w{add_user delete_user index login login_user}
  COORDINATOR_TERMINATE = %w{closed edit new open search}
  COORDINATOR_TICKET    = %w{add edit index open new}
  
  MANAGER_LOGIN         = %w{add_user delete_user index login login_user
                             lookup_user list_users}
  MANAGER_TERMINATE     = %w{closed edit new open search}
  MANAGER_TICKET        = %w{add edit index open new}
  
  REQUESTOR_LOGIN       = %w{index login login_user lookup_user}
  REQUESTOR_TERMINATE   = %w{edit new open search}
  REQUESTOR_TICKET      = %w{add edit index open new}
end