The Business Security Access Request system is used to track UH system account maintenance tasks.

*Note: This system has been retired.*

####Primary Development Tools
Ruby, version 1.8.6.
Rails, version 2.1.2
MySQL, version 5.1
Capistrano, version 2.5.8
CAS library (rubycas-client), version 2.0.1
LDAP library (ruby-net-ldap), version 0.0.4

####Rails gem Installations

######MySQL

      $ sudo gem install mysql --no-rdoc --no-ri --with-mysql-config=/usr/local/mysql/bin/mysql_config
Adjust mysql_config path as appropriate.

######CAS Authentication
      $ sudo gem install rubycas-client --no-rdoc --no-ri --version 2.0.1
  
######LDAP
      $ sudo gem install ruby-net-ldap
  
######Capistrano (deployment)
      $ sudo gem install capistrano
      $ sudo gem install capistrano-ext

####Application Locations
######Testing
  [http://www.test.hawaii.edu/bsar](http://www.test.hawaii.edu/bsar)

######Production

  [http://www.hawaii.edu/bsar](http://www.hawaii.edu/bsar)

####System Server Access
######Testing
  `its99.mgt.hawaii.edu` (application)
  
  `mdb74.pvt.hawaii.edu` (database)

######Production
  `its10.pvt.hawaii.edu` (application)
  
  `mdb40.pvt.hawaii.edu` (database)

######Using command line client to view database
  You can take a look at the production database from either its99 or its10.
  Here's one way (make sure to enter the real password):
  
      $ /usr/local/mysql/bin/mysql --user=bsar_admin --password=password --host=mdb40.pvt.hawaii.edu bsar
  
######Important Note
  Due to network security at UH, you may need to log in from a computer that can connect to the production server.
  For example, connect to utl05, then to its99 from there. Make sure to substitute the appropriate user name.
  
  For `http://www.test.hawaii.edu/bsar`
  
      $ local> ssh duckart@utl05.its.hawaii.edu
      
      $ utl05> ssh duckart@its99.mgt.hawaii.edu

  For `http://www.hawaii.edu/bsar`
  
      $ local> ssh duckart@utl10.its.hawaii.edu
      
      $ utl10> ssh duckart@its10.pvt.hawaii.edu


#####Deployment Process (with Capistrano)
The deployment of BSAR uses the Ruby-based Capistrano tool and a popular Capistrano extension that allows for a separate configuration for each defined environment. There are <em>test</em>, <em>staging</em>, and <em>production</em> environments defined for the application. The following example uses the production environment configuration.

###### 1. Run the primary setup

    $ cap production deploy:setup

###### 2. Run the check

    $ cap production deploy:check

###### 3. When ready, run the cold startup

    $ cap production deploy:cold
  
   
Note that after running the `deploy:cold` command, the system will be up and running.

#####Restart Instructions

In the event that the system is unresponsive or not accessible for any reason, the application can be stopped and restarted by using the following commands.
######1. Run stop
    $ cap production deploy:stop

######2. Run restart
    $ cap production deploy:restart

#####Operating System Environments
The BSAR application was initially developed and tested on Mac OS X and Microsoft Vista.

#####Important Note

The UH Number is restricted by University of Hawaii policy, so be sure not to expose it on any public page.

#####Outstanding Issues
Still using Rails code-based MySQL connectivity instead of the Solaris-specific library.  The build process on Production complains about the MySQL library and then seems to default to the code-based access.  The reason for the problem hasn't been determined.</li>

The Production application is running under the incorrect user account, and not with the bsard deamon account that was created specifically for the application.</li>

