local class = require "middleclass"
local inspect = require "inspect"
local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader

local ChannelUpdateDeserializer = class("ChannelUpdateDeserializer")

function ChannelUpdateDeserializer:initialize()
  self.name = "channel_update"
  self.number = 258
end

function ChannelUpdateDeserializer:deserialize(payload)
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
  local htlc_minimum_msat = string.unpack(">I8", packed_htlc_minimum_msat)
  local fee_base_msat = string.unpack(">I4", packed_fee_base_msat)
  local fee_proportional_millionths = string.unpack(">I4", packed_fee_proportional_millionths)

  local message_flags = string.unpack(">I1", packed_message_flags)
  local option_channel_htlc_max = 0 < bit32.band(message_flags, tonumber("10000000", 2))
  local message_flags_to_show = {}
  if option_channel_htlc_max then
    table.insert(message_flags_to_show, "option_channel_htlc_max")
  end

  local channel_flags = string.unpack(">I1", packed_channel_flags)
  local channel_flags_display = {
    direction = 0 < bit32.band(channel_flags, tonumber("10000000", 2)),
    disable = 0 < bit32.band(channel_flags, tonumber("01000000", 2))
  }

  local result = {
    signature = bin.stohex(packed_signature),
    chain_hash = bin.stohex(packed_chain_hash),
    short_channel_id = bin.stohex(packed_short_channel_id),
    timestamp = {
      Raw = bin.stohex(packed_timestamp),
      Deserialized = timestamp
    },
    message_flags = {
      Raw = bin.stohex(packed_message_flags),
      Deserialized = message_flags_to_show
    },
    channel_flags = {
      Raw = bin.stohex(packed_channel_flags),
      Deserialized = inspect(channel_flags_display)
    },
    cltv_expiry_delta = {
      Raw = bin.stohex(packed_cltv_expiry_delta),
      Deserialized = cltv_expiry_delta
    },
    htlc_minimum_msat = {
      Raw = bin.stohex(packed_htlc_minimum_msat),
      Deserialized = htlc_minimum_msat
    },
    fee_base_msat = {
      Raw = bin.stohex(packed_fee_base_msat),
      Deserialized = fee_base_msat
    },
    fee_proportional_millionths = {
      Raw = bin.stohex(packed_fee_proportional_millionths),
      Deserialized = fee_proportional_millionths
    }
  }

  if option_channel_htlc_max then
    local packed_htlc_maximum_msat = reader:read(8)
    local htlc_maximum_msat = string.unpack(">I8", packed_htlc_maximum_msat)

    result["htlc_maximum_msat"] = {
      Raw = bin.stohex(packed_htlc_maximum_msat),
      Deserialized = htlc_maximum_msat
    }
  end

  return result
end

return ChannelUpdateDeserializer
