#!/usr/bin/env ruby

# file: apphttp.rb

# desc: Makes it trivial to web enable a Ruby project

require 'socket'
require 'apphtml_layer'


class AppHttp
  using ColouredText

  def initialize(app, host: '0.0.0.0', port: '9232', filepath: '.', 
                 headings: true, debug: false)
    
    @app, @host, @port, @debug = app, host, port, debug
    @filepath, @headings = filepath, headings
    @ah = AppHtmlLayer.new(app, filepath: filepath, headings: headings, 
                      debug: debug)
    
  end

  def start

    server = TCPServer.new(@host, @port)

    while (session = server.accept)


      raw_request = session.gets
      request = raw_request[/.[^\s]+(?= HTTP\/1\.\d)/].strip

      puts ('request: ' + request.inspect).debug if @debug
      result, content_type = get(request)
      puts ('content_type: ' + content_type.inspect).debug if @debug

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
    @ah.lookup s
  end
end
