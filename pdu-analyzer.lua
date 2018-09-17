local class = require "middleclass"
local bin = require "plc52.bin"

local deserializers = {
  require("lightning-dissector.deserializers.init"):new(),
  require("lightning-dissector.deserializers.ping"):new(),
  require("lightning-dissector.deserializers.pong"):new(),
  require("lightning-dissector.deserializers.error"):new(),
  require("lightning-dissector.deserializers.channel-announcement"):new(),
  require("lightning-dissector.deserializers.channel-update"):new(),
  require("lightning-dissector.deserializers.node-announcement"):new()
}

local function find_deserializer_for(type)
  for _, deserializer in pairs(deserializers) do
    if deserializer.number == type then
      return deserializer
    end
  end
end

local function deserialize(packed_msg)
  local packed_type = packed_msg:sub(1, 2)
  local type = string.unpack(">I2", packed_type)
  local payload = packed_msg:sub(3)

  local result = {
    Type = {
      Raw = bin.stohex(packed_type),
      Number = type
    }
  }

  local deserializer = find_deserializer_for(type)
  if deserializer == nil then
    return result
  end

  result.Type.Name = deserializer.name

  local deserialized = deserializer:deserialize(payload)
  for key, value in pairs(deserialized) do
    result[key] = value
  end

  return result
end

local PduAnalyzer = class("PduAnalyzer")

function PduAnalyzer:initialize(secret_manager)
  self.secret_manager = secret_manager
end

function PduAnalyzer:analyze(pinfo, buffer)
  local secret = self.secret_manager:find_secret(pinfo, buffer)
  if secret == nil then
    return {
      Phase = "Handshake",
      Note = "Handshake never ends? Be sure that you correctly configured lightning-dissector by Wireshark's settings panel."
    }
  end

  local secret_before_decryption = secret:clone()

  local packed_encrypted_len = buffer():raw(0, 2)
  local packed_len_mac = buffer():raw(2, 16)
  local packed_decrypted_len = secret:decrypt(packed_encrypted_len, packed_len_mac)
  local decrypted_len = string.unpack(">I2", packed_decrypted_len)

  local packed_encrypted_msg = buffer:raw(18, decrypted_len)
  local packed_msg_mac = buffer:raw(18 + decrypted_len, 16)

  local packed_decrypted_msg = secret:decrypt(packed_encrypted_msg, packed_msg_mac)

  return {
    Secret = {
      Key = bin.stohex(secret_before_decryption:packed_key()),
      Nonce = {
        Raw = bin.stohex(secret_before_decryption:packed_nonce()),
        Deserialized = secret_before_decryption:nonce()
      }
    },
    Length = {
      Encrypted = bin.stohex(packed_encrypted_len),
      MAC = bin.stohex(packed_len_mac),
      Decrypted = bin.stohex(packed_decrypted_len),
      Deserialized = decrypted_len
    },
    Message = {
      Encrypted = bin.stohex(packed_encrypted_msg),
      MAC = bin.stohex(packed_msg_mac),
      Decrypted = bin.stohex(packed_decrypted_msg),
      Deserialized = deserialize(packed_decrypted_msg)
    }
  }
end

return PduAnalyzer
