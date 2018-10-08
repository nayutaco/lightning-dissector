local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_byteslen = reader:read(2)
  local byteslen = string.unpack(">I2", packed_byteslen)
  local packed_ignored = reader:read(byteslen)

  return OrderedDict:new(
    "byteslen", OrderedDict:new(
      "Raw", bin.stohex(packed_byteslen),
      "Deserialized", byteslen
    ),
    "ignored", bin.stohex(packed_ignored)
  )
end

return {
  number = 19,
  name = "pong",
  deserialize = deserialize
}
