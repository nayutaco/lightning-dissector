local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_id = reader:read(8)
  local packed_payment_preimage = reader:read(32)

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "id", OrderedDict:new(
      "Raw", bin.stohex(packed_id),
      "Deserialized", (string.unpack(">I8", packed_id))
    ),
    "payment_preimage", bin.stohex(packed_payment_preimage)
  )
end

return {
  number = 130,
  name = "update_fulfill_htlc",
  deserialize = deserialize
}
