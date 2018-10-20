local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_temporary_channel_id = reader:read(32)
  local packed_funding_txid = reader:read(32)
  local packed_funding_output_index = reader:read(2)
  local packed_signature = reader:read(64)

  return OrderedDict:new(
    "temporary_channel_id", bin.stohex(packed_temporary_channel_id),
    "funding_txid", bin.stohex(packed_funding_txid),
    "funding_output_index", OrderedDict:new(
      "Raw", bin.stohex(packed_funding_output_index),
      "Deserialized", (string.unpack(">I2", packed_funding_output_index))
    ),
    "signature", OrderedDict:new(
      "Raw", bin.stohex(packed_signature),
      "DER", bin.stohex(convert_signature_der(packed_signature))
    )
  )
end

return {
  number = 34,
  name = "funding_created",
  deserialize = deserialize
}
