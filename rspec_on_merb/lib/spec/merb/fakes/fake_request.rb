require 'stringio'
module Spec
  module Merb
    module Fakes
      class FakeRequest < ::Merb::Request
        attr_accessor :env, :req

        def initialize(o={}, method=nil)
          env = {
            'SERVER_NAME' => "#{o[:server_name]||'localhost'}",
            'PATH_INFO' => "#{o[:path_info]||'/'}",
            'HTTP_ACCEPT_ENCODING' => 'gzip,deflate',
            'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.8.0.1) Gecko/20060214 Camino/1.0',
            'SCRIPT_NAME' => '/',
            'SERVER_PROTOCOL' => 'HTTP/1.1',
            'HTTP_CACHE_CONTROL' => 'max-age=0',
            'HTTP_ACCEPT_LANGUAGE' => 'en,ja;q=0.9,fr;q=0.9,de;q=0.8,es;q=0.7,it;q=0.7,nl;q=0.6,sv;q=0.5,nb;q=0.5,da;q=0.4,fi;q=0.3,pt;q=0.3,zh-Hans;q=0.2,zh-Hant;q=0.1,ko;q=0.1',
            'HTTP_HOST' => 'localhost',
            'REMOTE_ADDR' => '127.0.0.1',
            'SERVER_SOFTWARE' => 'Mongrel 1.1',
            'HTTP_KEEP_ALIVE' => '300',
            'HTTP_REFERER' => "#{o[:http_referer]||'http://localhost/'}",
            'HTTP_ACCEPT_CHARSET' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
            'HTTP_VERSION' => 'HTTP/1.1',
            'REQUEST_URI' => "#{o[:request_uri]||'/'}",
            'SERVER_PORT' => '80',
            'GATEWAY_INTERFACE' => 'CGI/1.2',
            'HTTP_ACCEPT' => "#{o[:http_accept]||'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'}",
            'HTTP_CONNECTION' => 'keep-alive',
            'REQUEST_METHOD' => "#{o[:request_method]||'GET'}",
          }
          super env, method
          self.post_body=''
        end

        def self.with(path, o={})
          new({:request_uri => path,
              :path_info => path.sub(/\?.*$/,'')}.merge(o))
        end

        def params
          @env
        end

        def post_body=(post)
          @req = StringIO.new(post)
        end

        def body
          @req
        end

        def set(key, val)
          @env[key] = val
        end

        def to_hash
          @env
        end

        def [](key)
          @env[key]
        end

        def []=(key, value)
          @env[key] = value
        end

      end      
    end
  end
end