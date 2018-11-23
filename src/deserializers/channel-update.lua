local inspect = require "inspect"
local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local convert_signature_der = require("lightning-dissector.utils").convert_signature_der
local deserialize_flags = require("lightning-dissector.utils").deserialize_flags
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local deserialize_short_channel_id = require("lightning-dissector.utils").deserialize_short_channel_id
local fields = require("lightning-dissector.constants").fields

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_signature = reader:read(64)
  local packed_chain_hash = reader:read(32)
  local packed_short_channel_id = reader:read(8)
  local packed_timestamp = reader:read(4)
  local packed_message_flags = reader:read(1)
  local packed_channel_flags = reader:read(1)
  local packed_cltv_expiry_delta = reader:read(2)
  local packed_htlc_minimum_msat = reader:read(8)
  local packed_fee_base_msat = reader:read(4)
  local packed_fee_proportional_millionths = reader:read(4)

  local timestamp = string.unpack(">I4", packed_timestamp)
  local cltv_expiry_delta = string.unpack(">I2", packed_cltv_expiry_delta)
  local htlc_minimum_msat = UInt64.decode(packed_htlc_minimum_msat, false)
  local fee_base_msat = string.unpack(">I4", packed_fee_base_msat)
  local fee_proportional_millionths = string.unpack(">I4", packed_fee_proportional_millionths)

  local result = OrderedDict:new(
    "signature", OrderedDict:new(
      fields.payload.deserialized.signature.raw, bin.stohex(packed_signature),
      fields.payload.deserialized.signature.der, bin.stohex(convert_signature_der(packed_signature))
    ),
    fields.payload.deserialized.chain_hash, bin.stohex(packed_chain_hash),
    "short_channel_id", OrderedDict:new(
      fields.payload.deserialized.short_channel_id.raw, bin.stohex(packed_short_channel_id),
      fields.payload.deserialized.short_channel_id.deserialized, deserialize_short_channel_id(packed_short_channel_id)
    ),
    "timestamp", OrderedDict:new(
      fields.payload.deserialized.timestamp.raw, bin.stohex(packed_timestamp),
      fields.payload.deserialized.timestamp.deserialized, timestamp
    ),
    "message_flags", OrderedDict:new(
      fields.payload.deserialized.message_flags.raw, bin.stohex(packed_message_flags),
      fields.payload.deserialized.message_flags.deserialized, inspect(deserialize_flags(packed_message_flags, {"option_channel_htlc_max"}))
    ),
    "channel_flags", OrderedDict:new(
      fields.payload.deserialized.channel_flags.raw, bin.stohex(packed_channel_flags),
      fields.payload.deserialized.channel_flags.deserialized, inspect(deserialize_flags(packed_channel_flags, {"direction", "disable"}))
    ),
    "cltv_expiry_delta", OrderedDict:new(
      fields.payload.deserialized.cltv_expiry_delta.raw, bin.stohex(packed_cltv_expiry_delta),
      fields.payload.deserialized.cltv_expiry_delta.deserialized, cltv_expiry_delta
    ),
    "htlc_minimum_msat", OrderedDict:new(
      fields.payload.deserialized.htlc_minimum_msat.raw, bin.stohex(packed_htlc_minimum_msat),
      fields.payload.deserialized.htlc_minimum_msat.deserialized, htlc_minimum_msat
    ),
    "fee_base_msat", OrderedDict:new(
      fields.payload.deserialized.fee_base_msat.raw, bin.stohex(packed_fee_base_msat),
      fields.payload.deserialized.fee_base_msat.deserialized, fee_base_msat
    ),
    "fee_proportional_millionths", OrderedDict:new(
      fields.payload.deserialized.fee_proportional_millionths.raw, bin.stohex(packed_fee_proportional_millionths),
      fields.payload.deserialized.fee_proportional_millionths.deserialized, fee_proportional_millionths
    )
  )

  if option_channel_htlc_max then
    local packed_htlc_maximum_msat = reader:read(8)
    local htlc_maximum_msat = UInt64.decode(packed_htlc_maximum_msat, false)

    result.append("htlc_maximum_msat", OrderedDict:new(
      fields.payload.deserialized.htlc_maximum_msat.raw, bin.stohex(packed_htlc_maximum_msat),
      fields.payload.deserialized.htlc_maximum_msat.deserialized, htlc_maximum_msat
    ))
  end

  return result
end

return {
  name = "channel_update",
  number = 258,
  deserialize = deserialize
}
