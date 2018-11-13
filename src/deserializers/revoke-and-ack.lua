local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_per_commitment_secret = reader:read(32)
  local packed_next_per_commitment_point = reader:read(33)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    f.per_commitment_secret, bin.stohex(packed_per_commitment_secret),
    f.next_per_commitment_point, bin.stohex(packed_next_per_commitment_point)
  )
end

return {
  number = 133,
  name = "revoke_and_ack",
  deserialize = deserialize
}
