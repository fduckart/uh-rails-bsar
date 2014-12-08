require 'net/ldap'

LDAP_SERVER   = 'ldap1.its.hawaii.edu'  
LDAP_PORT     = 636
LDAP_TREEBASE = 'ou=people,dc=hawaii,dc=edu'
LDAP_USERNAME = 'cn=bsar,ou=Specials,dc=hawaii,dc=edu'
LDAP_PASSWORD = 'Sp6kE2z'

TYPE_USERNAME = 'uid'       # Move this somewhere shareable.
TYPE_USERID   = 'uhuuid'    # Move this somewhere shareable.

class PersonLookupController < ApplicationController

  def lookup_by_username(username)
    return lookup_user(username, TYPE_USERNAME)
  end
  
  def lookup_by_userid(uhuuid)
    return lookup_user(uhuuid, TYPE_USERID)
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private
  
  def lookup_user(value, key = TYPE_USERNAME)
    
    # Guard to check input values.
    # \w == letter or digit; same as [0-9A-Za-z]
    value.each_char { |c| 
      if !(c =~ /\w/)
        return nil        
      end
    }
    
    # Guard for empty lookup key or value.
    if key.to_s.empty? or value.to_s.empty? 
      return nil
    end
    
    return find_user_via_ldap(key, value)    
  end

  def find_user_via_ldap(key, value)
    ldap = Net::LDAP.new
    ldap.host = LDAP_SERVER
    ldap.port = LDAP_PORT
    ldap.encryption :simple_tls
    ldap.authenticate(LDAP_USERNAME, LDAP_PASSWORD)
    attributes = ["uid", "uhuuid", "mail", "displayName", 
                  "givenName", "sn", "title", "telephoneNumber", "ou", "cn"]
    presence_filter = Net::LDAP::Filter.pres TYPE_USERNAME
    filter = Net::LDAP::Filter.eq(key, value)
    filters = presence_filter & filter
    ldap.search({:base => LDAP_TREEBASE, 
                 :filter => filters, 
                 :attributes => attributes}) do |entry|
      p = Person.new
      p.firstname = entry['givenName'][0]
      p.lastname = entry['sn'][0]
      p.uid = entry[TYPE_USERNAME][0]
      p.uhuuid = entry['uhuuid'][0]
      p.email = entry['mail'][0]
      p.title = entry['title'][0]
      p.department = entry['ou'][0] 
      p.system = entry['ou'][1] 
      p.phone = entry['telephoneNumber'][0]
      
      # Determine the user display or full name.
      
      display_name = entry['displayName'][0]
      if (display_name.nil?)
        display_name = entry['cn'][0]     
     end
      p.display_name = display_name 
      
      return p
    end
    
    return nil   # Did not find entry.
  end

end
  
