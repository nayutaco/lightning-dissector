local bin = require "plc52.bin"
local inspect = require "inspect"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local deserialize_flags = require("lightning-dissector.utils").deserialize_flags
local f = require("lightning-dissector.constants").fields.payload.deserialized

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

  local result = OrderedDict:new(
    f.chain_hash, bin.stohex(packed_chain_hash),
    f.temporary_channel_id, bin.stohex(packed_temporary_channel_id),
    "funding_satoshis", OrderedDict:new(
      f.funding_satoshis.raw, bin.stohex(packed_funding_satoshis),
      f.funding_satoshis.deserialized, UInt64.decode(packed_funding_satoshis, false)
    ),
    "push_msat", OrderedDict:new(
      f.push_msat.raw, bin.stohex(packed_push_msat),
      f.push_msat.deserialized, UInt64.decode(packed_push_msat, false)
    ),
    "dust_limit_satoshis", OrderedDict:new(
      f.dust_limit_satoshis.raw, bin.stohex(packed_dust_limit_satoshis),
      f.dust_limit_satoshis.deserialized, UInt64.decode(packed_dust_limit_satoshis, false)
    ),
    "max_htlc_value_in_flight_msat", OrderedDict:new(
      f.max_htlc_value_in_flight_msat.raw, bin.stohex(packed_max_htlc_value_in_flight_msat),
      f.max_htlc_value_in_flight_msat.deserialized, UInt64.decode(packed_max_htlc_value_in_flight_msat, false)
    ),
    "channel_reserve_satoshis", OrderedDict:new(
      f.channel_reserve_satoshis.raw, bin.stohex(packed_channel_reserve_satoshis),
      f.channel_reserve_satoshis.deserialized, UInt64.decode(packed_channel_reserve_satoshis, false)
    ),
    "htlc_minimum_msat", OrderedDict:new(
      f.htlc_minimum_msat.raw, bin.stohex(packed_htlc_minimum_msat),
      f.htlc_minimum_msat.deserialized, UInt64.decode(packed_htlc_minimum_msat, false)
    ),
    "feerate_per_kw", OrderedDict:new(
      f.feerate_per_kw.raw, bin.stohex(packed_feerate_per_kw),
      f.feerate_per_kw.deserialized, (string.unpack(">I4", packed_feerate_per_kw))
    ),
    "to_self_delay", OrderedDict:new(
      f.to_self_delay.raw, bin.stohex(packed_to_self_delay),
      f.to_self_delay.deserialized, (string.unpack(">I2", packed_to_self_delay))
    ),
    "max_accepted_htlcs", OrderedDict:new(
      f.max_accepted_htlcs.raw, bin.stohex(packed_max_accepted_htlcs),
      f.max_accepted_htlcs.deserialized, (string.unpack(">I2", packed_max_accepted_htlcs))
    ),
    f.funding_pubkey, bin.stohex(packed_funding_pubkey),
    f.revocation_basepoint, bin.stohex(packed_revocation_basepoint),
    f.payment_basepoint, bin.stohex(packed_payment_basepoint),
    f.delayed_payment_basepoint, bin.stohex(packed_delayed_payment_basepoint),
    f.htlc_basepoint, bin.stohex(packed_htlc_basepoint),
    f.first_per_commitment_point, bin.stohex(packed_first_per_commitment_point),
    "channel_flags", OrderedDict:new(
      f.channel_flags.raw, bin.stohex(packed_channel_flags),
      f.channel_flags.deserialized, inspect(deserialize_flags(packed_channel_flags, {"announce_channel"}))
    )
  )

  if reader:has_next() then
    local packed_shutdown_len = reader:read(2)
    local shutdown_len = string.unpack(">I2", packed_shutdown_len)
    local packed_shutdown_scriptpubkey = reader:read(shutdown_len)

    result:append("shutdown_len", OrderedDict:new(
      f.shutdown_len.raw, bin.stohex(packed_shutdown_len),
      f.shutdown_len.deserialized, shutdown_len
    ))
    result:append(f.shutdown_scriptpubkey, bin.stohex(packed_shutdown_scriptpubkey))
  end

  return result
end

return {
  number = 32,
  name = "open_channel",
  deserialize = deserialize
}
