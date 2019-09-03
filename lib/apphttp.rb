#!/usr/bin/env ruby

# file: apphttp.rb

# desc: Makes it trivial to web enable a Ruby project

require 'socket'
require 'json'


class AppHttp

  def initialize(app, host: '0.0.0.0', port: '9232', debug: false)
    @app, @host, @port, @debug = app, host, port, debug
  end

  def start

    server = TCPServer.new(@host, @port)

    while (session = server.accept)

      raw_request = session.gets
      request = raw_request[/.[^\s]+(?= HTTP\/1\.\d)/].strip

      result,content_type = get(request)
      puts 'content_type: ' + content_type.inspect if @debug

      if result then
        response = result
      else
        response = "404: page not found"
        content_type = 'text/plain'
      end

      session.print "HTTP/1.1 200 OK\r\nContent-type: #{content_type}\r\n" + 
                "Content-Length: #{response.bytesize}\r\n" +
                "Connection: close\r\n"
      session.print "\r\n"
      session.print response
      session.close
    end
  end

  private

  def get(s)

    args = []

    if s.count('/') > 1 then

      name, args = *s.split('/')[1..-1]

    else

      name, raw_params = s[/(?<=^\/).*/].split('?',2)

      if raw_params then

        raw_pairs = raw_params.split('&')

        h = raw_pairs.inject({}) do |r,x|
          key,value = x.split('=',2)
          r.merge(key.to_sym => value) if value
        end

        return unless h

        h2 = h.inject({}) do |r,x|

          if x.first.to_s =~ /^arg/ then
            args << x.last
          else
            r.merge!(x.first => x.last)
          end
          r
        end

        args << h2 if h2.any?

      end

    end    

    if @app.respond_to? name.to_sym then

      begin
        r = @app.method(name.to_sym).call(*args)
      rescue
        r = ($!).inspect
      end

      case r.class.to_s
      when "String"
        [r, 'text/plain']
      when "Hash"
        [r.to_json,'application/json']
      else
        [r.to_s, 'text/plain']
      end
    end

  end

end
