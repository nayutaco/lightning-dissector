local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_id = reader:read(8)
  local packed_amount_msat = reader:read(8)
  local packed_payment_hash = reader:read(32)
  local packed_cltv_expiry = reader:read(4)
  local packed_onion_routing_packet = reader:read(1366)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "id", OrderedDict:new(
      f.id.raw, bin.stohex(packed_id),
      f.id.deserialized, UInt64.decode(packed_id, false)
    ),
    "amount_msat", OrderedDict:new(
      f.amount_msat.raw, bin.stohex(packed_amount_msat),
      f.amount_msat.deserialized, UInt64.decode(packed_amount_msat, false)
    ),
    f.payment_hash, bin.stohex(packed_payment_hash),
    "cltv_expiry", OrderedDict:new(
      f.cltv_expiry.raw, bin.stohex(packed_cltv_expiry),
      f.cltv_expiry.deserialized, (string.unpack(">I4", packed_cltv_expiry))
    ),
    f.onion_routing_packet, bin.stohex(packed_onion_routing_packet)
  )
end

return {
  number = 128,
  name = "update_add_htlc",
  deserialize = deserialize
}
