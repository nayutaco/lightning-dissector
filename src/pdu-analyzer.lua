local OrderedDict = require("lightning-dissector.utils").OrderedDict
local bin = require "plc52.bin"
local constants = require "lightning-dissector.constants"

local deserializers = {
  require("lightning-dissector.deserializers.init"),
  require("lightning-dissector.deserializers.ping"),
  require("lightning-dissector.deserializers.pong"),
  require("lightning-dissector.deserializers.error"),
  require("lightning-dissector.deserializers.channel-announcement"),
  require("lightning-dissector.deserializers.channel-update"),
  require("lightning-dissector.deserializers.node-announcement"),
  require("lightning-dissector.deserializers.open-channel"),
  require("lightning-dissector.deserializers.accept-channel")
}

local function find_deserializer_for(type)
  for _, deserializer in ipairs(deserializers) do
    if deserializer.number == type then
      return deserializer
    end
  end
end

local function deserialize(packed_payload)
  local packed_type = packed_payload:sub(1, 2)
  local type = string.unpack(">I2", packed_type)
  local payload = packed_payload:sub(3)

  local deserializer = find_deserializer_for(type)
  if deserializer == nil then
    return OrderedDict:new(
      "Type", OrderedDict:new(
        "Raw", bin.stohex(packed_type),
        "Number", type
      )
    )
  end

  local result = OrderedDict:new(
    "Type", OrderedDict:new(
      "Raw", bin.stohex(packed_type),
      "Name", deserializer.name,
      "Number", type
    )
  )

  local deserialized = deserializer.deserialize(payload)
  for key, value in pairs(deserialized) do
    result:append(key, value)
  end

  return result
end

local function analyze_length(buffer, secret)
  local packed_encrypted = buffer():raw(0, constants.lengths.length)
  local packed_mac = buffer():raw(constants.lengths.length, constants.lengths.length_mac)
  local packed_decrypted = secret:decrypt(packed_encrypted, packed_mac)
  local deserialized = string.unpack(">I2", packed_decrypted)

  return {
    packed_encrypted = packed_encrypted,
    packed_mac = packed_mac,
    packed_decrypted = packed_decrypted,
    deserialized = deserialized,
    display = function()
      return OrderedDict:new(
        "Encrypted", bin.stohex(packed_encrypted),
        "Decrypted", bin.stohex(packed_decrypted),
        "Deserialized", deserialized,
        "MAC", bin.stohex(packed_mac)
      )
    end
  }
end

local function analyze_payload(buffer, secret)
  local payload_length = buffer:len() - constants.lengths.footer
  local packed_encrypted = buffer:raw(0, payload_length)
  local packed_mac = buffer:raw(payload_length, constants.lengths.payload_mac)
  local packed_decrypted = secret:decrypt(packed_encrypted, packed_mac)

  return {
    packed_encrypted = packed_encrypted,
    packed_mac = packed_mac,
    packed_decrypted = packed_decrypted,
    display = function()
      return OrderedDict:new(
        "Encrypted", bin.stohex(packed_encrypted),
        "MAC", bin.stohex(packed_mac),
        "Decrypted", bin.stohex(packed_decrypted),
        "Deserialized", deserialize(packed_decrypted)
      )
    end
  }
end

return {
  analyze_length = analyze_length,
  analyze_payload = analyze_payload
}
