module Multipart
  require 'rubygems'
  require 'mime/types'

  class Param
    attr_accessor :k, :v
    def initialize( k, v )
      @k = k
      @v = v
    end

    def to_multipart
      return "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n#{v}\r\n"
    end
  end

  class FileParam
    attr_accessor :k, :filename, :content
    def initialize( k, filename, content )
      @k = k
      @filename = filename
      @content = content
    end

    def to_multipart
      return "Content-Disposition: form-data; name=\"#{k}\"; filename=\"#{filename}\"\r\n" + "Content-Type: #{MIME::Types.type_for(@filename)}\r\n\r\n" + content + "\r\n"
    end
  end
  class Post
    attr_accessor :parameters
    
    BOUNDARY = '----------0xKhTmLbOuNdArY'
    CONTENT_TYPE = "multipart/form-data, boundary=" + BOUNDARY

    def prepare_query(params, multipart=false)
      fp = []
      params.each {|k,v|
        if v.respond_to?(:read)
          fp.push(FileParam.new(k, v.path, c=v.read))
        else
          fp.push(Param.new(k,v))
        end
      }
      return to_multipart(fp)
    end
    def to_multipart(fp)
      query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
      return query, CONTENT_TYPE
    end
  end  
end
