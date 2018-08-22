local class = require "middleclass"
local bin = require "plc.bin"
local Reader = require "lightning-dissector.utils.reader"

local PingDeserializer = class("PingDeserializer")

function PingDeserializer:initialize()
  self.number = 18
  self.name = "ping"
end

function PingDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local num_pong_bytes = string.unpack(">I2", reader:read(2))
  local byteslen = string.unpack(">I2", reader:read(2))
  local ignored = bin.stohex(reader:read(byteslen))

  return {
    num_pong_bytes = num_pong_bytes,
    byteslen = byteslen,
    ignored = ignored
  }
end

return PingDeserializer
