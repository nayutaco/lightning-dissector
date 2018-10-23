local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_id = reader:read(8)
  local packed_len = reader:read(2)
  local len = string.unpack(">I2", packed_len)
  local packed_reason = reader:read(len)

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "id", OrderedDict:new(
      "Raw", bin.stohex(packed_id),
      "Deserialized", (string.unpack(">I8", packed_id))
    ),
    "len", OrderedDict:new(
      "Raw", bin.stohex(paced_len),
      "Deserialized", len
    ),
    "reason", bin.stohex(packed_reason)
  )
end

return {
  number = 131,
  name = "update_fail_htlc",
  deserialize = deserialize
}
