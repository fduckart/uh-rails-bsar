class DummyPersonFinder < PersonLookupController
  
  def initialize(people = nil, authenticator = nil)
    super(authenticator)

    people   = Array.new
    @uhuuids = Hash.new
    @uids    = Hash.new
    
    p = Person.new
    p.uhuuid = '17958670'
    p.uid = 'duckart'
    p.display_name = 'Frank Duckart'
    p.firstname = 'Frank'
    p.lastname = 'Duckart'
    people << p
    
    p2 = Person.new
    p2.uhuuid = '17232418'
    p2.uid = 'jaimeyh'
    p2.display_name = 'Jaimey Hamilton'
    p2.firstname = 'Jaimey'
    p2.lastname = 'Hamilton'
    people << p2
    
    p3 = Person.new
    p3.uhuuid = '10967714'
    p3.uid = 'cahana'
    p3.display_name = 'Cameron Ahana'
    p3.firstname = 'Cameron'
    p3.lastname = 'Ahana'
    people << p3
    
    p4 = Person.new
    p4.uhuuid = '11111111'
    p4.uid = 'davis'
    people << p4
    
    p = Person.new
    p.uhuuid = '19407388'
    p.uid = 'amek'
    people << p
    
    for p in people
      @uhuuids[p.uhuuid] = p
      @uids[p.uid] = p
    end
  end
    
  def find_user_via_ldap(key, value)
    if (key.eql?('uhuuid'))
      user = @uhuuids[value]
    else
      user = @uids[value]
    end
  
    return user
  end  
  
end