module NginxTail
  module RemoteUser

    #
    # to easily identify remote and authenticated users, for filtering and formatting purposes
    #
    # e.g. add all employees as authenticated remote users (from your webserver's .htaccess file)
    #

    UNKNOWN_REMOTE_USER = "-".freeze # the 'default' nginx value for the $remote_user variable

    def self.included(base) # :nodoc:
      base.class_eval do

        @@authenticated_users = []

        # mainly (solely?) for testing purposes...
        def self.reset_authenticated_users
          while !@@authenticated_users.empty? ; @@authenticated_users.pop ; end
        end
        
        # mainly (solely?) for testing purposes...
        def self.authenticated_users
          @@authenticated_users.dup
        end
        
        def self.add_authenticated_user(authenticated_user)
          raise "Cannot add unkown remote user" if self.unknown_remote_user? authenticated_user
          (@@authenticated_users << authenticated_user).uniq!
        end

        def self.unknown_remote_user?(remote_user)
          remote_user == UNKNOWN_REMOTE_USER
        end

        def self.remote_user?(remote_user)
          !self.unknown_remote_user?(remote_user)
        end
        
        def self.authenticated_user?(remote_user)
          self.remote_user?(remote_user) && @@authenticated_users.include?(remote_user)
        end

      end
    end

  end
end