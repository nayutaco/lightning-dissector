local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_id = reader:read(8)
  local packed_payment_preimage = reader:read(32)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "id", OrderedDict:new(
      f.id.raw, bin.stohex(packed_id),
      f.id.deserialized, UInt64.decode(packed_id, false)
    ),
    f.payment_preimage, bin.stohex(packed_payment_preimage)
  )
end

return {
  number = 130,
  name = "update_fulfill_htlc",
  deserialize = deserialize
}
