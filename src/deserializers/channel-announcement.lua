local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local convert_signature_der = require("lightning-dissector.utils").convert_signature_der
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
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

  return OrderedDict:new(
    "node_signature_1", OrderedDict:new(
      f.node_signature_1.raw, bin.stohex(packed_node_signature_1),
      f.node_signature_1.der, bin.stohex(convert_signature_der(packed_node_signature_1))
    ),
    "node_signature_2", OrderedDict:new(
      f.node_signature_2.raw, bin.stohex(packed_node_signature_2),
      f.node_signature_2.der, bin.stohex(convert_signature_der(packed_node_signature_2))
    ),
    "bitcoin_signature_1", OrderedDict:new(
      f.bitcoin_signature_1.raw, bin.stohex(packed_bitcoin_signature_1),
      f.bitcoin_signature_1.der, bin.stohex(convert_signature_der(packed_bitcoin_signature_1))
    ),
    "bitcoin_signature_2", OrderedDict:new(
      f.bitcoin_signature_2.raw, bin.stohex(packed_bitcoin_signature_2),
      f.bitcoin_signature_2.der, bin.stohex(convert_signature_der(packed_bitcoin_signature_2))
    ),
    "len", OrderedDict:new(
      f.len.raw, bin.stohex(packed_len),
      f.len.deserialized, len
    ),
    f.features, bin.stohex(packed_features),
    f.chain_hash, bin.stohex(packed_chain_hash),
    f.short_channel_id, bin.stohex(packed_short_channel_id),
    f.node_id_1, bin.stohex(packed_node_id_1),
    f.node_id_2, bin.stohex(packed_node_id_2),
    f.bitcoin_key_1, bin.stohex(packed_bitcoin_key_1),
    f.bitcoin_key_2, bin.stohex(packed_bitcoin_key_2)
  )
end

return {
  number = 256,
  name = "channel_announcement",
  deserialize = deserialize
}
