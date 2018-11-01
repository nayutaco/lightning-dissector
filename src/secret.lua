local class = require "middleclass"
local chacha20 = require "plc52.chacha20"
local poly1305 = require "poly1305"
local bin = require "plc52.bin"
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local fields = require("lightning-dissector.constants").fields

local function pad16(s)
  return (#s % 16 == 0) and "" or ('\0'):rep(16 - (#s % 16))
end

local Secret = class("Secret")

function Secret:initialize(packed_key, nonce)
  self._packed_key = packed_key  -- const readonly
  self.nonce = nonce or 0
end

function Secret:packed_key()
  return self._packed_key
end

function Secret:packed_nonce()
  return "\x00\x00\x00\x00" .. string.pack("I8", self.nonce)
end

function Secret:decrypt(packed_msg, packed_mac)
  if not self:can_decrypt(packed_msg, packed_mac) then
    error("MAC does not match")
  end

  local decrypted = chacha20.decrypt(self:packed_key(), 1, self:packed_nonce(), packed_msg)
  if decrypted == nil then
    error("MAC is correct, but can't decrypt the message")
  end

  self.nonce = self.nonce + 1
  return decrypted
end

function Secret:can_decrypt(packed_msg, packed_mac)
  local mac_key = chacha20.encrypt(self:packed_key(), 0, self:packed_nonce(), ("\0"):rep(32))
  local mac_msg = packed_msg .. pad16(packed_msg) .. string.pack('<I8', 0) .. string.pack('<I8', #packed_msg)
  local calculated_mac = poly1305.auth(mac_msg, mac_key)

  return calculated_mac == packed_mac
end

function Secret:clone()
  local clone = {
    _packed_key = self._packed_key,
    nonce = self.nonce
  }

  return setmetatable(clone, {__index = self})
end

function Secret:display()
  return OrderedDict:new(
    fields.secret.key, bin.stohex(self:packed_key()),
    "Nonce", OrderedDict:new(
      fields.secret.nonce.raw, bin.stohex(self:packed_nonce()),
      fields.secret.nonce.deserialized, self.nonce
    )
  )
end

return Secret
