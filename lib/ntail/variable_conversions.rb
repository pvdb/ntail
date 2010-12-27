module NginxTail
  module VariableConversions
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # >> DateTime.strptime("13/Apr/2010:04:45:51 +0100", '%d/%b/%Y:%T %z').to_s
        # => "2010-04-13T04:45:51+01:00"
        # >> DateTime.strptime("13/Apr/2010:04:45:51 +0100", '%d/%b/%Y:%H:%M:%S %z').to_s
        # => "2010-04-13T04:45:51+01:00"
        # >> _

        def self.to_date(time_local)
          DateTime.strptime(time_local, '%d/%b/%Y:%T %z')
        end
        
        def self.to_date_s(time_local, format = "%Y-%m-%d %X")
          self.to_date(time_local).strftime(format)
        end
        
      end
    end
    
  end
end