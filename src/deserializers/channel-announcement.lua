local class = require "middleclass"
local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader

local ChannelAnnouncementDeserializer = class("ChannelAnnouncementDeserializer")

function ChannelAnnouncementDeserializer:initialize()
  self.number = 256
  self.name = "channel_announcement"
end

function ChannelAnnouncementDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local packed_node_signature_1 = reader:read(64)
  local packed_node_signature_2 = reader:read(64)
  local packed_bitcoin_signature_1 = reader:read(64)
  local packed_bitcoin_signature_2 = reader:read(64)
  local packed_len = reader:read(2)
  local len = string.unpack(">I2", packed_len)
  local packed_features = reader:read(len)
  local packed_chain_hash = reader:read(32)
  local packed_short_channel_id = reader:read(8)
  local packed_node_id_1 = reader:read(33)
  local packed_node_id_2 = reader:read(33)
  local packed_bitcoin_key_1 = reader:read(33)
  local packed_bitcoin_key_2 = reader:read(33)

  return {
    node_signature_1 = bin.stohex(packed_node_signature_1),
    node_signature_2 = bin.stohex(packed_node_signature_2),
    bitcoin_signature_1 = bin.stohex(packed_bitcoin_signature_1),
    bitcoin_signature_2 = bin.stohex(packed_bitcoin_signature_2),
    len = {
      Raw = bin.stohex(packed_len),
      Deserialized = len
    },
    features = bin.stohex(packed_features),
    chain_hash = bin.stohex(packed_chain_hash),
    short_channel_id = bin.stohex(packed_short_channel_id),
    node_id_1 = bin.stohex(packed_node_id_1),
    node_id_2 = bin.stohex(packed_node_id_2),
    bitcoin_key_1 = bin.stohex(packed_bitcoin_key_1),
    bitcoin_key_2 = bin.stohex(packed_bitcoin_key_2)
  }
end

return ChannelAnnouncementDeserializer
