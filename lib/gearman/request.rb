module Gearman
  class Request

    MAGIC = "\0REQ"

    def initialize(type, *arguments)
      @body = arguments.join("\0")
      @header = [type, @body.size].pack('NN')
    end

    def to_s
      "#{MAGIC}#{@header}#{@body}"
    end

    def ==(request)
      request.to_s == to_s
    end

  end
end
