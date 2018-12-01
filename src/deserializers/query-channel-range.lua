local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_chain_hash = reader:read(32)
  local packed_first_blocknum = reader:read(4)
  local packed_number_of_blocks = reader:read(4)

  return OrderedDict:new(
    f.chain_hash, bin.stohex(packed_chain_hash),
    "first_blocknum", OrderedDict:new(
      f.first_blocknum.raw, bin.stohex(packed_first_blocknum),
      f.first_blocknum.deserialized, (string.unpack(">I4", packed_first_blocknum))
    ),
    "number_of_blocks", OrderedDict:new(
      f.number_of_blocks.raw, bin.stohex(packed_number_of_blocks),
      f.number_of_blocks.deserialized, (string.unpack(">I4", packed_number_of_blocks))
    )
  )
end

return {
  number = 263,
  name = "query_channel_range",
  deserialize = deserialize
}
