local class = require "middleclass"
local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader

local PongDeserializer = class("PongDeserializer")

function PongDeserializer:initialize()
  self.number = 19
  self.name = "pong"
end

function PongDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local packed_byteslen = reader:read(2)
  local byteslen = string.unpack(">I2", packed_byteslen)
  local packed_ignored = reader:read(byteslen)

  return {
    byteslen = {
      Raw = bin.stohex(packed_byteslen),
      Deserialized = byteslen
    },
    ignored = bin.stohex(packed_ignored)
  }
end

return PongDeserializer
