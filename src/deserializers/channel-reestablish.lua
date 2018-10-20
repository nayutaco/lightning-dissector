local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_next_local_commitment_number = reader:read(8)
  local packed_next_remote_revocation_number = reader:read(8)

  local result = OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "next_local_commitment_number", OrderedDict:new(
      "Raw", bin.stohex(packed_next_local_commitment_number),
      "Deserialized", (string.unpack(">I8", packed_next_local_commitment_number))
    ),
    "next_remote_revocation_number", OrderedDict:new(
      "Raw", bin.stohex(packed_next_remote_revocation_number),
      "Deserialized", (string.unpack(">I8", packed_next_remote_revocation_number))
    )
  )

  if reader:has_next() then
    local packed_your_last_per_commitment_secret = reader:read(32)
    local packed_my_current_per_commitment_point = reader:read(33)

    result:append("your_last_per_commitment_secret", bin.stohex(packed_your_last_per_commitment_secret))
    result:append("my_current_per_commitment_point", bin.stohex(packed_my_current_per_commitment_point))
  end

  return result
end

return {
  number = 136,
  name = "channel_reestablish",
  deserialize = deserialize
}
