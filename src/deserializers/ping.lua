local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_num_pong_bytes = reader:read(2)
  local num_pong_bytes = string.unpack(">I2", packed_num_pong_bytes)
  local packed_byteslen = reader:read(2)
  local byteslen = string.unpack(">I2", packed_byteslen)
  local packed_ignored = reader:read(byteslen)

  return OrderedDict:new(
    "num_pong_bytes", OrderedDict:new(
      f.num_pong_bytes.raw, bin.stohex(packed_num_pong_bytes),
      f.num_pong_bytes.deserialized, num_pong_bytes
    ),
    "byteslen", OrderedDict:new(
      f.byteslen.raw, bin.stohex(packed_byteslen),
      f.byteslen.deserialized, byteslen
    ),
    f.ignored, bin.stohex(packed_ignored)
  )
end

return {
  number = 18,
  name = "ping",
  deserialize = deserialize
}
