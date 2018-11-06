local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_len = reader:read(2)
  local len = string.unpack(">I2", packed_len)
  local data = reader:read(len)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "len", OrderedDict:new(
      f.len.raw, bin.stohex(packed_len),
      f.len.deserialized, len
    ),
    "data", OrderedDict:new(
      f.data.raw, bin.stohex(data),
      f.data.deserialized, data
    )
  )
end

return {
  number = 17,
  name = "error",
  deserialize = deserialize
}
