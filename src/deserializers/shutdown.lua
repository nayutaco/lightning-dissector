local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)

  local packed_len = reader:read(2)
  local len = string.unpack(">I2", packed_len)

  local packed_scriptpubkey = reader:read(len)

  return OrderedDict:new(
    "channel_id", bin.stohex(packed_channel_id),
    "len", len,
    "scriptpubkey", bin.stohex(packed_scriptpubkey)
  )
end

return {
  number = 38,
  name = "shutdown",
  deserialize = deserialize
}
