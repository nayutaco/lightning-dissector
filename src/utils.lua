local class = require "middleclass"
local bin = require "plc52.bin"

-- provides file-like read
local Reader = class("Reader")

function Reader:initialize(payload)
  self.payload = payload
  self.offset = 0
end

function Reader:read(how_many)
  local result = self.payload:sub(self.offset + 1, self.offset + how_many)
  self.offset = self.offset + how_many

  return result
end

function Reader:has_next()
  return self.payload:len() > self.offset
end

local OrderedDict = class("OrderedDict")

function OrderedDict:initialize(...)
  local args = {...}
  self.keys = {}
  self.values = {}

  for i = 1, #args do
    self.keys[i] = args[(i - 1) * 2 + 1]
    self.values[i] = args[(i - 1) * 2 + 2]
  end
end

function OrderedDict:append(key, value)
  table.insert(self.keys, key)
  table.insert(self.values, value)
end

function OrderedDict:__pairs()
  local i = 0

  return function()
    i = i + 1

    if #self.keys < i then
      return nil
    else
      return self.keys[i], self.values[i]
    end
  end
end

function encode_signature_der(packed_r, packed_s)
  local packed_integers = {packed_r, packed_s}
  local packed_encoded_integers = {}
  for _, integer in ipairs(packed_integers) do
    local first_byte = tonumber(bin.stohex(integer:sub(1, 1)), 16)
    -- If the first bit is 0
    if first_byte == bit32.band(first_byte, tonumber("01111111", 2)) then
      table.insert(packed_encoded_integers, "\x02\x20" .. integer)
    else
      table.insert(packed_encoded_integers, "\x02\x21\x00" .. integer)
    end
  end

  local result_integer_part = table.concat(packed_encoded_integers)
  local result_length = bin.hextos(string.format("%02x", #result_integer_part))
  local result_seq = "\x30" .. result_length .. result_integer_part
  return result_seq
end

function convert_signature_der(packed_signature)
  local packed_r = packed_signature:sub(1, 32)
  local packed_s = packed_signature:sub(33, 64)

  return encode_signature_der(packed_r, packed_s)
end

function deserialize_flags(bytes, defined_flags)
  local byte = string.unpack(">I" .. #bytes, bytes)

  local enabled_flags = {}
  for i, flag in pairs(defined_flags) do
    local mask = bit32.lshift(1, i - 1)
    if 0 < bit32.band(byte, mask) then
      table.insert(enabled_flags, flag)
    end
  end

  return enabled_flags
end

function deserialize_short_channel_id(packed_short_channel_id)
  local packed_blocknum = packed_short_channel_id:sub(1, 3)
  local packed_txnum = packed_short_channel_id:sub(4, 6)
  local packed_outnum = packed_short_channel_id:sub(7, 8)

  local blocknum = string.unpack(">I3", packed_blocknum)
  local txnum = string.unpack(">I3", packed_txnum)
  local outnum = string.unpack(">I2", packed_outnum)

  return blocknum .. 'x' .. txnum .. 'x' .. outnum
end

return {
  Reader = Reader,
  OrderedDict = OrderedDict,
  encode_signature_der = encode_signature_der,
  convert_signature_der = convert_signature_der,
  deserialize_flags = deserialize_flags,
  deserialize_short_channel_id = deserialize_short_channel_id
}
