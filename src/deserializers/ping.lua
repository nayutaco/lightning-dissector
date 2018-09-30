local class = require "middleclass"
local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader

local PingDeserializer = class("PingDeserializer")

function PingDeserializer:initialize()
  self.number = 18
  self.name = "ping"
end

function PingDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local packed_num_pong_bytes = reader:read(2)
  local num_pong_bytes = string.unpack(">I2", packed_num_pong_bytes)
  local packed_byteslen = reader:read(2)
  local byteslen = string.unpack(">I2", packed_byteslen)
  local packed_ignored = reader:read(byteslen)

  return {
    num_pong_bytes = {
      Raw = bin.stohex(packed_num_pong_bytes),
      Deserialized = num_pong_bytes
    },
    byteslen = {
      Raw = bin.stohex(packed_byteslen),
      Deserialized = byteslen
    },
    ignored = bin.stohex(packed_ignored)
  }
end

return PingDeserializer
