local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local convert_signature_der = require("lightning-dissector.utils").convert_signature_der

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_signature = reader:read(64)

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "signature", OrderedDict:new(
      "Raw", bin.stohex(packed_signature),
      "DER", bin.stohex(convert_signature_der(packed_signature))
    )
  )
end

return {
  number = 35,
  name = "funding_signed",
  deserialize = deserialize
}
