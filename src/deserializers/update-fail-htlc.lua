local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_id = reader:read(8)
  local packed_len = reader:read(2)
  local len = string.unpack(">I2", packed_len)
  local packed_reason = reader:read(len)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "id", OrderedDict:new(
      f.id.raw, bin.stohex(packed_id),
      f.id.deserialized, UInt64.decode(packed_id, false)
    ),
    "len", OrderedDict:new(
      f.len.raw, bin.stohex(paced_len),
      f.len.deserialized, len
    ),
    f.reason, bin.stohex(packed_reason)
  )
end

return {
  number = 131,
  name = "update_fail_htlc",
  deserialize = deserialize
}
