local class = require "middleclass"
local Reader = require "lightning-dissector.utils.reader"

local ErrorDeserializer = class("ErrorDeserializer")

function ErrorDeserializer:initialize()
  self.number = 17
  self.name = "error"
end

function ErrorDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local channel_id = bin.stohex(reader:read(32))
  local len = string.unpack(">I2", reader:read(2))
  local data = reader:read(len)

  return {
    channel_id = channel_id,
    len = len,
    data = data
  }
end

return ErrorDeserializer
