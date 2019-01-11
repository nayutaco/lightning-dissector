local inspect = require "inspect"
local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local convert_signature_der = require("lightning-dissector.utils").convert_signature_der
local deserialize_flags = require("lightning-dissector.utils").deserialize_flags
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local deserialize_short_channel_id = require("lightning-dissector.utils").deserialize_short_channel_id
local f = require("lightning-dissector.constants").fields.payload.deserialized

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
  local message_flags = deserialize_flags(packed_message_flags, {"option_channel_htlc_max"})

  local result = OrderedDict:new(
    "signature", OrderedDict:new(
      f.signature.raw, bin.stohex(packed_signature),
      f.signature.der, bin.stohex(convert_signature_der(packed_signature))
    ),
    f.chain_hash, bin.stohex(packed_chain_hash),
    "short_channel_id", OrderedDict:new(
      f.short_channel_id.raw, bin.stohex(packed_short_channel_id),
      f.short_channel_id.deserialized, deserialize_short_channel_id(packed_short_channel_id)
    ),
    "timestamp", OrderedDict:new(
      f.timestamp.raw, bin.stohex(packed_timestamp),
      f.timestamp.deserialized, timestamp
    ),
    "message_flags", OrderedDict:new(
      f.message_flags.raw, bin.stohex(packed_message_flags),
      f.message_flags.deserialized, inspect(message_flags)
    ),
    "channel_flags", OrderedDict:new(
      f.channel_flags.raw, bin.stohex(packed_channel_flags),
      f.channel_flags.deserialized, inspect(deserialize_flags(packed_channel_flags, {"direction", "disable"}))
    ),
    "cltv_expiry_delta", OrderedDict:new(
      f.cltv_expiry_delta.raw, bin.stohex(packed_cltv_expiry_delta),
      f.cltv_expiry_delta.deserialized, cltv_expiry_delta
    ),
    "htlc_minimum_msat", OrderedDict:new(
      f.htlc_minimum_msat.raw, bin.stohex(packed_htlc_minimum_msat),
      f.htlc_minimum_msat.deserialized, htlc_minimum_msat
    ),
    "fee_base_msat", OrderedDict:new(
      f.fee_base_msat.raw, bin.stohex(packed_fee_base_msat),
      f.fee_base_msat.deserialized, fee_base_msat
    ),
    "fee_proportional_millionths", OrderedDict:new(
      f.fee_proportional_millionths.raw, bin.stohex(packed_fee_proportional_millionths),
      f.fee_proportional_millionths.deserialized, fee_proportional_millionths
    )
  )

  local option_channel_htlc_max = false
  for i = 1, #message_flags do
    if message_flags[i] == "option_channel_htlc_max" then
      option_channel_htlc_max = true
      break
    end
  end

  if option_channel_htlc_max then
    local packed_htlc_maximum_msat = reader:read(8)
    local htlc_maximum_msat = UInt64.decode(packed_htlc_maximum_msat, false)

    result:append("htlc_maximum_msat", OrderedDict:new(
      f.htlc_maximum_msat.raw, bin.stohex(packed_htlc_maximum_msat),
      f.htlc_maximum_msat.deserialized, htlc_maximum_msat
    ))
  end

  return result
end

return {
  name = "channel_update",
  number = 258,
  deserialize = deserialize
}
