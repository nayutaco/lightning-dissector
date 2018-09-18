local class = require "middleclass"
local chacha20 = require "plc52.chacha20"
local poly1305 = require "poly1305"

local function pad16(s)
  return (#s % 16 == 0) and "" or ('\0'):rep(16 - (#s % 16))
end

local function chacha20_poly1305_decrypt(packed_key, packed_nonce, packed_msg, packed_mac)
  local mac_key = chacha20.encrypt(packed_key, 0, packed_nonce, ("\0"):rep(32))
  local mac_msg = packed_msg .. pad16(packed_msg) .. string.pack('<I8', 0) .. string.pack('<I8', #packed_msg)
  local calculated_mac = poly1305.auth(mac_msg, mac_key)

  if packed_mac == calculated_mac then
    return chacha20.decrypt(packed_key, 1, packed_nonce, packed_msg)
  else
    return nil
  end
end

local Secret = class("Secret")

function Secret:initialize(packed_key)
  self._packed_key = packed_key  -- const readonly
  self._nonce = 0  -- readonly
end

function Secret:packed_key()
  return self._packed_key
end

function Secret:nonce()
  return self._nonce
end

function Secret:packed_nonce()
  return "\x00\x00\x00\x00" .. string.pack("I8", self._nonce)
end

function Secret:decrypt(packed_msg, packed_mac)
  local decrypted = chacha20_poly1305_decrypt(self:packed_key(), self:packed_nonce(), packed_msg, packed_mac)
  if decrypted == nil then
    error("Authentication failed: MAC does not match")
  end

  self._nonce = self._nonce + 1

  return decrypted
end

function Secret:clone()
  local clone = {
    _packed_key = self._packed_key,
    _nonce = self._nonce
  }

  return setmetatable(clone, {__index = self})
end

return Secret
