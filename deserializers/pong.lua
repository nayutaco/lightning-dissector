local class = require "middleclass"
local Reader = require "lightning-dissector.utils.reader"

local PongDeserializer = class("PongDeserializer")

function PongDeserializer:initialize()
  self.number = 19
  self.name = "pong"
end

function PongDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local byteslen = string.unpack(">I2", reader:read(2))
  local ignored = string.unpack(">I" .. byteslen, reader:read(byteslen))

  return {
    byteslen = byteslen,
    ignored = ignored
  }
end

return PongDeserializer
