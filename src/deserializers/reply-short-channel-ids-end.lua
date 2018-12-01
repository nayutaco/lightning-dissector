local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_chain_hash = reader:read(32)
  local packed_complete = reader:read(1)

  return OrderedDict:new(
    f.chain_hash, bin.stohex(packed_chain_hash),
    "complete", OrderedDict:new(
      f.complete.raw, bin.stohex(packed_complete),
      f.complete.deserialized, (string.unpack(">I1", packed_complete))
    )
  )
end

return {
  number = 262,
  name = "reply_short_channel_ids_end",
  deserialize = deserialize
}
