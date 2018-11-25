local bin = require "plc52.bin"
local zlib = require "zlib"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local deserialize_short_channel_id = require("lightning-dissector.utils").deserialize_short_channel_id
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_chain_hash = reader:read(32)
  local packed_len = reader:read(2)
  local len = string.unpack(">I2", packed_len)
  local packed_short_ids = reader:read(len)

  local encoding_type = string.unpack(">I1", packed_short_ids:sub(1, 1))
  local short_ids_payload = packed_short_ids:sub(2)

  local short_ids
  if encoding_type == 0 then
    short_ids = deserialize_short_ids(short_ids_payload)
  elseif encoding_type == 1 then
    local decompressed = zlib.inflate()(short_ids_payload)
    short_ids = deserialize_short_ids(decompressed)
  else
    error("Invalid encoding type")
  end

  return OrderedDict:new(
    f.chain_hash, bin.stohex(packed_chain_hash),
    "len", OrderedDict:new(
      f.len.raw, bin.stohex(packed_len),
      f.len.deserialized, len
    ),
    "encoded_short_ids", OrderedDict:new(
      f.encoded_short_ids.raw, bin.stohex(packed_short_ids),
      "Deserialized", short_ids
    )
  )
end

function deserialize_short_ids(short_ids)
  local reader = Reader:new(short_ids)

  local result = {}
  while reader:has_next() do
    local packed_short_id = reader:read(8)
    table.insert(result, OrderedDict:new(
      f.encoded_short_ids.deserialized.raw, packed_short_id,
      f.encoded_short_ids.deserialized.deserialized, deserialize_short_channel_id(packed_short_id)
    ))
  end

  return result
end

return {
  number = 261,
  name = "query_short_channel_ids",
  deserialize = deserialize
}
