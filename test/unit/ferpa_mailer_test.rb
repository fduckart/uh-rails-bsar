require File.dirname(__FILE__) + '/../test_helper'

class FerpaMailerTest < ActionMailer::TestCase
  tests FerpaMailer

  def test_sent
    user = Person.new
    user.email = 'duckart@hawaii.edu'
    
    @expected.subject = 'FERPA Notice'
    @expected.from = 'duckart@hawaii.edu'
    @expected.to = ['fduckart@hotmail.com', user.email]
    @expected.body    = read_fixture('notice')
    @expected.date    = Time.now
    
    response = FerpaMailer.create_notice(user)
    assert_equal @expected.encoded, response.encoded
  end

  def test_reminder
    person = Person.new
    person.uid = 'duckart'
    person.email = 'duckart@hawaii.edu'
    
    @expected.subject = 'FERPA Reminder'
    @expected.from = 'duckart@hawaii.edu'
    @expected.to = ['fduckart@hotmail.com', person.email]
    
    @expected.body    = read_fixture('reminder')
    @expected.date    = Time.now 

    email = FerpaMailer.create_reminder(person)
    
    assert_equal @expected.encoded.gsub(/\r/, ''), email.encoded.gsub(/\r/, '')
  end
  
end
