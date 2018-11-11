local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_fee_satoshis = reader:read(8)
  local packed_signature = reader:read(64)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "fee_satoshis", OrderedDict:new(
      f.fee_satoshis.raw, bin.stohex(packed_fee_satoshis),
      f.fee_satoshis.deserialized, UInt64.decode(packed_fee_satoshis, false)
    ),
    "signature", OrderedDict:new(
      f.signature.raw, bin.stohex(packed_signature),
      f.signature.der, bin.stohex(convert_signature_der(packed_signature))
    )
  )
end

return {
  number = 39,
  name = "closing_signed",
  deserialize = deserialize
}
