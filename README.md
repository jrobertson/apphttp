# Introducing the apphttp gem

## Usage

    require 'apphttp'


    class Fun

      def initialize()
      end

      def go()
        'go 123'
      end

      def hello(name)
        'hello ' + name
      end

      def food(apples: 0, grapes: 0)
        {apples: apples, grapes: grapes}
      end

    end

    rws = AppHttp.new(Fun.new, port: '9292', debug: true)
    rws.start

The above example runs a simple web server which can query methods from an aribtrary object, in this case from a class called Fun.

Output
<pre>
http://127.0.0.1:9292/go #=> go 123
http://127.0.0.1:9292/hello?arg=James #=> hello James
http://127.0.0.1:9292/food?apples=34 #=> {"apples":"34","grapes":0}
</pre>

## Resources

* apphttp https://rubygems.org/gems/apphttp

apphttp http webserver tcp server
