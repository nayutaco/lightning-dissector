local bin = require "plc52.bin"
local inspect = require "inspect"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local deserialize_flags = require("lightning-dissector.utils").deserialize_flags

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_chain_hash = reader:read(32)
  local packed_temporary_channel_id = reader:read(32)
  local packed_funding_satoshis = reader:read(8)
  local packed_push_msat = reader:read(8)
  local packed_dust_limit_satoshis = reader:read(8)
  local packed_max_htlc_value_in_flight_msat = reader:read(8)
  local packed_channel_reserve_satoshis = reader:read(8)
  local packed_htlc_minimum_msat = reader:read(8)
  local packed_feerate_per_kw = reader:read(4)
  local packed_to_self_delay = reader:read(2)
  local packed_max_accepted_htlcs = reader:read(2)
  local packed_funding_pubkey = reader:read(33)
  local packed_revocation_basepoint = reader:read(33)
  local packed_payment_basepoint = reader:read(33)
  local packed_delayed_payment_basepoint = reader:read(33)
  local packed_htlc_basepoint = reader:read(33)
  local packed_first_per_commitment_point = reader:read(33)
  local packed_channel_flags = reader:read(1)

  local channel_flags = deserialize_flags(packed_channel_flags, {
    [8] = "announce_channel"
  })

  local result = OrderedDict:new(
    "chain_hash", bin.stohex(packed_chain_hash),
    "temporary_channel_id", bin.stohex(packed_temporary_channel_id),
    "funding_satoshis", OrderedDict:new(
      "Raw", bin.stohex(packed_funding_satoshis),
      "Deserialized", (string.unpack(">I8", packed_funding_satoshis))
    ),
    "push_msat", OrderedDict:new(
      "Raw", bin.stohex(packed_push_msat),
      "Deserialized", (string.unpack(">I8", packed_push_msat))
    ),
    "dust_limit_satoshis", OrderedDict:new(
      "Raw", bin.stohex(packed_dust_limit_satoshis),
      "Deserialized", (string.unpack(">I8", packed_dust_limit_satoshis))
    ),
    "max_htlc_value_in_flight_msat", OrderedDict:new(
      "Raw", bin.stohex(packed_max_htlc_value_in_flight_msat),
      "Deserialized", (string.unpack(">I8", packed_max_htlc_value_in_flight_msat))
    ),
    "channel_reserve_satoshis", OrderedDict:new(
      "Raw", bin.stohex(packed_channel_reserve_satoshis),
      "Deserialized", (string.unpack(">I8", packed_channel_reserve_satoshis))
    ),
    "htlc_minimum_msat", OrderedDict:new(
      "Raw", bin.stohex(packed_htlc_minimum_msat),
      "Deserialized", (string.unpack(">I8", packed_htlc_minimum_msat))
    ),
    "feerate_per_kw", OrderedDict:new(
      "Raw", bin.stohex(packed_feerate_per_kw),
      "Deserialized", (string.unpack(">I4", packed_feerate_per_kw))
    ),
    "to_self_delay", OrderedDict:new(
      "Raw", bin.stohex(packed_to_self_delay),
      "Deserialized", (string.unpack(">I2", packed_to_self_delay))
    ),
    "max_accepted_htlcs", OrderedDict:new(
      "Raw", bin.stohex(packed_max_accepted_htlcs),
      "Deserialized", (string.unpack(">I2", packed_max_accepted_htlcs))
    ),
    "funding_pubkey", bin.stohex(packed_funding_pubkey),
    "revocation_basepoint", bin.stohex(packed_revocation_basepoint),
    "payment_basepoint", bin.stohex(packed_payment_basepoint),
    "delayed_payment_basepoint", bin.stohex(packed_delayed_payment_basepoint),
    "htlc_basepoint", bin.stohex(packed_htlc_basepoint),
    "first_per_commitment_point", bin.stohex(packed_first_per_commitment_point),
    "channel_flags", OrderedDict:new(
      "Raw", bin.stohex(packed_channel_flags),
      "Deserialized", inspect(channel_flags)
    )
  )

  if reader:has_next() then
    local packed_shutdown_len = reader:read(2)
    local shutdown_len = string.unpack(">I2", packed_shutdown_len)
    local packed_shutdown_scriptpubkey = reader:read(shutdown_len)

    result:append("shutdown_len", OrderedDict:new(
      "Raw", bin.stohex(packed_shutdown_len),
      "Deserialized", shutdown_len
    ))
    result:append("shutdown_scriptpubkey", bin.stohex(packed_shutdown_scriptpubkey))
  end

  return result
end

return {
  number = 32,
  name = "open_channel",
  deserialize = deserialize
}
