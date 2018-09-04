local class = require "middleclass"
local bin = require "plc.bin"
local Reader = require "lightning-dissector.utils.reader"

local ErrorDeserializer = class("ErrorDeserializer")

function ErrorDeserializer:initialize()
  self.number = 17
  self.name = "error"
end

function ErrorDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_len = reader:read(2)
  local len = string.unpack(">I2", reader:read(2))
  local data = reader:read(len)

  return {
    channel_id = bin.stohex(packed_channel_id),
    len = {
      Raw = bin.stohex(packed_len),
      Deserialized = len
    },
    data = {
      Raw = bin.stohex(data),
      Deserialized = data
    }
  }
end

return ErrorDeserializer
