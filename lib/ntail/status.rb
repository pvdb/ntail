module NginxTail
  module Status
    
    NGINX_MAGIC_STATUS = '499'   # ex-standard HTTP response code specific to nginx, in addition to http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    
    def self.included(base) # :nodoc:
      base.class_eval do

        # Informational 1xx
        def self.information_status?(status)
          # (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPInformation
          (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_CLASS_TO_OBJ[(status.to_i / 100).to_s] == Net::HTTPInformation
        end
        
        # Successful 2xx
        def self.success_status?(status)
          # (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPSuccess
          (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_CLASS_TO_OBJ[(status.to_i / 100).to_s] == Net::HTTPSuccess
        end
        
        # Redirection 3xx
        def self.redirect_status?(status)
          # (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPRedirection
          (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_CLASS_TO_OBJ[(status.to_i / 100).to_s] == Net::HTTPRedirection
        end
        
        # Client Error 4xx
        def self.client_error_status?(status)
          # (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPClientError
          (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_CLASS_TO_OBJ[(status.to_i / 100).to_s] == Net::HTTPClientError
        end
        
        # Internal Server Error 5xx
        def self.server_error_status?(status)
          # (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_TO_OBJ[status.to_s] <= Net::HTTPServerError
          (status.to_s != NGINX_MAGIC_STATUS) and Net::HTTPResponse::CODE_CLASS_TO_OBJ[(status.to_i / 100).to_s] == Net::HTTPServerError
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'status'" unless base.instance_methods.include? 'status'
        
      end
    end

    def information_status?
      self.class.information_status?(self.status)
    end

    def success_status?
      self.class.success_status?(self.status)
    end

    def redirect_status?
      self.class.redirect_status?(self.status)
    end

    def client_error_status?
      self.class.client_error_status?(self.status)
    end

    def server_error_status?
      self.class.server_error_status?(self.status)
    end
        
  end
end


