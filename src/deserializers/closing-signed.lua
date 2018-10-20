local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_fee_satoshis = reader:read(8)
  local packed_signature = reader:read(64)

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "fee_satoshis", OrderedDict:new(
      "Raw", bin.stohex(packed_fee_satoshis),
      "Deserialized", (string.unpack(">I8", packed_fee_satoshis))
    ),
    "signature", OrderedDict:new(
      "Raw", bin.stohex(packed_signature),
      "DER", bin.stohex(convert_signature_der(packed_signature))
    )
  )
end

return {
  number = 39,
  name = "closing_signed",
  deserialize = deserialize
}
