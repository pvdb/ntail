module NginxTail
  module Uri
    
    def self.included(base) # :nodoc:
      base.class_eval do

        #
        # files in the "public" folder of the web root
        # which are requested automagically, by things
        # like browsers, Facebook, search engines, ...
        #

        @@default_automatic_files = %w{
          xd_receiver.html
          crossdomain.xml
          favicon.ico
          sitemap.xml
          robots.txt
        }

        @@automatic_files = [] ; @@automatic_uris = []

        # mainly (solely?) for testing purposes...
        def self.automatic_files()
          @@automatic_files.dup
        end

        # mainly (solely?) for testing purposes...
        def self.automatic_uris()
          @@automatic_uris.dup
        end

        # mainly (solely?) for testing purposes...
        def self.reset_automatic_files()
          while !@@automatic_files.empty? ; @@automatic_files.pop ; end
          while !@@automatic_uris.empty? ; @@automatic_uris.pop ; end
          self.add_automatic_file(@@default_automatic_files)
        end

        def self.add_automatic_file(automatic_file)
          if automatic_file.is_a? Array
            # some ducktyping, so that we can also accepts arrays of values
            automatic_file.each { |file| self.add_automatic_file(file) }
          else
            (@@automatic_files << automatic_file).uniq!
            (@@automatic_uris << Regexp.compile("^\/#{automatic_file}")).uniq!
          end
        end

        # populate with default values...
        self.reset_automatic_files

        def self.automatic_uri?(uri)
          !@@automatic_uris.detect { |automatic_uri_regexp| uri.match(automatic_uri_regexp) }.nil?
        end

        #
        # subdirectories of the "public" folder in the web root,
        # which - in a typical Rails setup - are served by nginx
        #

        @@static_repos = %w{
          flash
          html
          images
          javascripts
          js
          movies
          newsletters
          pictures
          stylesheets
          css
          xml
        }

        @@static_uris = @@static_repos.map { |repo| Regexp.compile("^\/#{repo}\/") }

        def self.add_static_repo(repo)
          # TODO make this DRY...
          @@static_uris << Regexp.compile("^\/#{repo}\/")
        end

        def self.static_uri?(uri)
          !@@static_uris.detect { |static_uri_regexp| uri.match(static_uri_regexp) }.nil?
        end

        def self.to_uri_s(uri)
          uri || "-" # will be nil if $request == "-" (ie. "dodgy" HTTP requests)
        end

        # this ensures the below module methods actually make sense...
        raise "Class #{base.name} should implement instance method 'uri'" unless base.instance_methods.map(&:to_s).include? 'uri'
        
      end
    end
    
    def to_uri_s
      self.class.to_uri_s(self.uri)
    end

    def automatic_uri?
      self.class.automatic_uri?(self.uri)
    end

    def static_uri?
      self.class.static_uri?(self.uri)
    end
    
  end
end
