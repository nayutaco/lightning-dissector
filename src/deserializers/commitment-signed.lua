local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_signature = reader:read(64)
  local packed_num_htlcs = reader:read(2)
  local num_htlcs = string.unpack(">I2", packed_num_htlcs)

  local signatures = {}
  for i = 1, num_htlcs do
    local packed_signature = reader:read(64)
    table.insert(signatures, OrderedDict:new(
      "Raw", bin.stohex(packed_signature),
      "DER", bin.stohex(convert_signature_der(packed_signature))
    ))
  end

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "signature", OrderedDict:new(
      "Raw", bin.stohex(packed_signature),
      "DER", bin.stohex(convert_signature_der(packed_signature))
    ),
    "num_htlcs", OrderedDict:new(
      "Raw", bin.stohex(packed_num_htlcs),
      "Deserialized", num_htlcs
    ),
    "htlc_siganture", signatures
  )
end

return {
  number = 132,
  name = "commitment_signed",
  deserialize = deserialize
}
