module Geary
  module Packet
    module Magic
      REQUEST = "\0REQ" unless defined? REQUEST
      RESPONSE = "\0RES" unless defined? RESPONSE
    end
  end
end
