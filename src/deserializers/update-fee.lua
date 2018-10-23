local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_feerate_per_kw = reader:read(4)

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "feerate_per_kw", OrderedDict:new(
      "Raw", bin.stohex(packed_feerate_per_kw),
      "Deserialized", (string.unpack(">I4", packed_feerate_per_kw))
    )
  )
end

return {
  number = 134,
  name = "update_fee",
  deserialize = deserialize
}
