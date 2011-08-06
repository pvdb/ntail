ntail
=====

A `tail(1)`-like utility for nginx log files that supports parsing, filtering and formatting of individual 
log lines (in nginx's so-called ["combined" log format](http://wiki.nginx.org/NginxHttpLogModule#log_format)).

<a name="intro"/>

Check it out, yo!
-----------------

Instead of this...

<pre style="background-color: black; color: white; padding: 15px; width: 1100px; overflow: hidden; text-overflow: ellipsis;">
<span style="color:white;">$ tail -f /var/log/nginx/access.log</span>
<span style="color: green;">192.0.32.10 - - [21/Jan/2011:14:07:34 +0000] "GET / HTTP/1.1" 200 3700 "-" "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.237 Safari/534.10" "-"</span>
<span style="color: green;">192.0.32.10 - - [21/Jan/2011:14:07:34 +0000] "GET /nginx-logo.png HTTP/1.1" 200 370 "http://localhost/" "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.237 Safari/534.10" "-"</span>
<span style="color: green;">192.0.32.10 - - [21/Jan/2011:14:07:34 +0000] "GET /poweredby.png HTTP/1.1" 200 3034 "http://localhost/" "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.237 Safari/534.10" "-"</span>
<span style="color: green;">192.0.32.10 - - [21/Jan/2011:14:07:34 +0000] "GET /favicon.ico HTTP/1.1" 404 3650 "-" "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.237 Safari/534.10" "-"</span>
<span style="color: green;">192.0.32.10 - - [21/Jan/2011:14:19:04 +0000] "GET /nginx-logo.png HTTP/1.1" 304 0 "-" "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.237 Safari/534.10" "-"</span>
<span style="color:white;">$ _</span>
</pre>

... you get this:

<pre style="background-color: black; padding: 15px; width: 800px;">
<span style="color:white;">$ tail -f /var/log/nginx/access.log <strong>| ntail</strong></span>
<span style="color: green;">2011-01-21 14:07:34 -       192.0.32.10 - 200 - GET / - (Chrome, Linux) - -</span>
<span style="color: green;">2011-01-21 14:07:34 -       192.0.32.10 - 200 - GET /nginx-logo.png - (Chrome, Linux) - localhost</span>
<span style="color: green;">2011-01-21 14:07:34 -       192.0.32.10 - 200 - GET /spanoweredby.png - (Chrome, Linux) - localhost</span>
<span style="color: red;">2011-01-21 14:07:34 -       192.0.32.10 - 404 - GET /favicon.ico - (Chrome, Linux) - -</span>
<span style="color: orange;">2011-01-21 14:19:04 -       192.0.32.10 - 304 - GET /nginx-logo.png - (Chrome, Linux) - -</span>
<span style="color:white;">$ _</span>
</pre>

<a name="installation"/>

Installation
------------

Installing the gem also installs the `ntail` executable, typically as `/usr/bin/ntail` or `/usr/local/bin/ntail`:

    $ gem install ntail

To ensure easy execution of the `ntail` script, add the actual installation directory to your shell's `$PATH` variable.

<a name="basic"/>

Basic Usage
-----------

* process an entire nginx log file and print each parsed and formatted line to STDOUT

        $ ntail /var/log/nginx/access.log

* tail an "active" nginx log file and print each new line to STDOUT _(stop with ^C)_

        $ tail -f /var/log/nginx/access.log | ntail

<a name="advanced"/>

Advanced Examples
-----------------

* read from STDIN and print each line to STDOUT _(stop with ^D)_

        $ ntail

* read from STDIN and print out the length of each line _(to illustrate -e option)_

        $ ntail -e 'puts size'

* read from STDIN but only print out non-empty lines _(to illustrate -f option)_

        $ ntail -f 'size != 0'

* the following invocations behave exactly the same _(to illustrate -e and -f options)_

        $ ntail
        $ ntail -f 'true' -e 'puts self'

* print out all HTTP requests that are coming from a given IP address

        $ ntail -f 'remote_address == "208.67.222.222"' /var/log/nginx/access.log

* find all HTTP requests that resulted in a '5xx' HTTP error/status code _(e.g. Rails 500 errors)_

        $ gunzip -S .gz -c access.log-20101216.gz | ntail -f 'server_error_status?'

* generate a summary report of HTTP status codes, for all non-200 HTTP requests

        $ ntail -f 'status != "200"' -e 'puts status' access.log | sort | uniq -c
        76 301
        16 302
         2 304
         1 406

* print out GeoIP country and city information for each HTTP request _(depends on the optional `geoip` gem)_

        $ ntail -e 'puts [to_country_s, to_city_s].join("\t")' /var/log/nginx/access.log
        United States   Los Angeles
        United States   Houston
        Germany         Berlin
        United Kingdom  London

* print out the IP address and the corresponding host name for each HTTP request _(slows things down considerably, due to `nslookup` call)_

        $ ntail -e 'puts [remote_address, to_host_s].join("\t")' /var/log/nginx/access.log
        66.249.72.196   crawl-66-249-72-196.googlebot.com
        67.192.120.134  s402.pingdom.com
        75.31.109.144   adsl-75-31-109-144.dsl.irvnca.sbcglobal.net
    
<a name="todo"/>

TODO
----
    
* implement a native `"-f"` option for ntail, similar to that of `tail(1)`, using e.g. flori's [file-tail gem](https://github.com/flori/file-tail)
* implement a `"-i"` option ("ignore exceptions"/"continue processing"), if handling a single line raises an exception
* or indeed a reverse `"-r"` option ("re-raise exception"), to immediately stop processing and raising the exception for investigation
* implement (better) support for custom nginx log formats, in addition to [nginx's default "combined" log format](http://wiki.nginx.org/NginxHttpLogModule#log_format).

<a name="acknowledgements"/>

Acknowledgements
----------------

* ntail's parsing feature is inspired by an nginx log parser written by [Richard Taylor (moomerman)](https://github.com/moomerman)
* parsing and expanding ntail's formatting string is done using nathansobo's quite brilliant [treetop gem](https://github.com/nathansobo/treetop)
* Kudos to [Ed James (edjames)](https://github.com/edjames) for recommending the use of [instance_eval][eval] to clean up the DSL

[eval]: https://github.com/pvdb/ntail/commit/b0f40522012b9858c433808cd1f5c21cb455fadd "use instance_eval to simplify the DSL"

<a name="contributing"/>

Contributing to ntail
---------------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

<a name="copyright"/>

Copyright
---------

Copyright (c) 2011 Peter Vandenberk. See LICENSE.txt for further details.

