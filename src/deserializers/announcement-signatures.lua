local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized
local deserialize_short_channel_id = require("lightning-dissector.utils").deserialize_short_channel_id
local convert_signature_der = require("lightning-dissector.utils").convert_signature_der

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_short_channel_id = reader:read(8)
  local packed_node_signature = reader:read(64)
  local packed_bitcoin_signature = reader:read(64)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "short_channel_id", OrderedDict:new(
      f.short_channel_id.raw, bin.stohex(packed_short_channel_id),
      f.short_channel_id.deserialized, deserialize_short_channel_id(packed_short_channel_id)
    ),
    "node_signature", OrderedDict:new(
      f.node_signature.raw, bin.stohex(packed_node_signature),
      f.node_signature.der, bin.stohex(convert_signature_der(packed_node_signature))
    ),
    "bitcoin_signature", OrderedDict:new(
      f.bitcoin_signature.raw, bin.stohex(packed_bitcoin_signature),
      f.bitcoin_signature.der, bin.stohex(convert_signature_der(packed_bitcoin_signature))
    )
  )
end

return {
  number = 259,
  name = "announcement_signatures",
  deserialize = deserialize
}
