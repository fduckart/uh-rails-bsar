require 'rubygems'
require 'rufus/scheduler'
require 'ferpa_mailer'

module NotificationsHelper

  class Runner
    def run 
      user = Person.new
      user.email = 'duckart@computer.org'
      FerpaMailer.deliver_notice(user)
    end
  end
  
  class Notifier
    class << self
      def Notifier.start
        @scheduler = Rufus::Scheduler.start_new
        @scheduler.schedule("*/1 * * * *") do
          Runner.new.run 
        end
      end
    end  # self
  end  # class

end  # module