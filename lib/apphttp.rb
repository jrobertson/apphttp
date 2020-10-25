#!/usr/bin/env ruby

# file: apphttp.rb

# desc: Makes it trivial to web enable a Ruby project

require 'socket'
require 'json'
require 'c32'
require 'kramdown'


class AppHttp
  using ColouredText

  def initialize(app, host: '0.0.0.0', port: '9232', filepath: '.', 
                 headings: true, debug: false)
    
    @app, @host, @port, @debug = app, host, port, debug
    @filepath, @headings = filepath, headings
    
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

    if s == '/' then
      
      fp = File.join(@filepath, 'index.html')      
      return (File.exists?(fp) ? File.read(fp) : default_index() )

    end
   
    return [s.to_s, 'text/plain'] if s =~ /^\/\w+\.\w+/

    args = []

    if s.count('/') > 1 then

      name, args = *s.split('/')[1..-1]

    else
      puts ('s: ' + s.inspect).debug if @debug
      name, raw_params = s[/(?<=^\/).*/].split('?',2)

      if raw_params then

        puts ('raw_params: ' + raw_params.inspect).debug if @debug
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
        
        method = @app.method(name.to_sym)
        
        if method.arity > 0 and  args.length <= 0 then
          r = "
          <form action='#{name}'>
            <input type='text' name='arg'></input>
            <input type='submit'/>
          </form>"
        else
          r = method.call(*args)
        end

        fp = File.join(@filepath, File.basename(name) + '.html')

        content = if File.exists?(fp) then        
          render_html(fp, r)
        else

          if @headings then
            markdown = "
# #{name.capitalize}          

<output>#{r}</output>
"

            Kramdown::Document.new(markdown).to_html
          else
            
            r
          end


        end

      rescue
        content = ($!).inspect
      end

      case content.class.to_s
      when "String"
        media = content.lstrip[0] == '<' ? 'html' : 'plain'
        [content, 'text/' + media]
      when "Hash"
        [content.to_json,'application/json']
      else
        [content.to_s, 'text/plain']
      end
    end

  end
  
  def default_index()
    
    a = (@app.public_methods - Object.public_methods).sort
    s = a.map {|x| "* [%s](%s)" % [x,x]}.join("\n")

    markdown = "
<html>
  <head>
  <title>#{@app.class.to_s}</title>
  <style>
h1 {color: green}
h2 {color: orange}
div {height: 60%; overflow-y: auto; width: 200px; float: left}
  </style>
  </head>
<body markdown='1'>

# #{@app.class.to_s} Index

## Public Methods

<div markdown='1'>
#{s}
</div>
<iframe name='i1'></iframe>
<div style='clear: both' />
<hr/>
</body>
</html>    
    "    
    #markdown = s
    doc = Rexle.new(Kramdown::Document.new(markdown).to_html)
    
    doc.root.xpath('body/div/ul/li/a') do |link|
      link.attributes[:target] = 'i1'
    end
    
    [doc.xml(pretty: true), 'text/html']    
  end
  
  def render_html(fp, s)
    
    doc = Rexle.new(File.read fp)
    e = doc.root.element('//[@class="output"]')    
    e.text = s
    

    doc.xml pretty: true    
    
  end

end
