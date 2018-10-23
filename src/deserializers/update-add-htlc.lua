local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_id = reader:read(8)
  local packed_amount_msat = reader:read(8)
  local packed_payment_hash = reader:read(32)
  local packed_cltv_expiry = reader:read(4)
  local packed_onion_routing_packet = reader:read(1366)

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "id", OrderedDict:new(
      "Raw", bin.stohex(packed_id),
      "Deserialized", (string.unpack(">I8", packed_id))
    ),
    "amount_msat", OrderedDict:new(
      "Raw", bin.stohex(packed_amount_msat),
      "Deserialized", (string.unpack(">I8", packed_id))
    ),
    "payment_hash", bin.stohex(packed_payment_hash),
    "cltv_expiry", OrderedDict:new(
      "Raw", bin.stohex(packed_cltv_expiry),
      "Deserialized", (string.unpack(">I4", packed_cltv_expiry))
    ),
    "onion_routing_packet", bin.stohex(packed_onion_routing_packet)
  )
end

return {
  number = 128,
  name = "update_add_htlc",
  deserialize = deserialize
}
