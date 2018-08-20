require "compat53"
local chacha = require "plc.chacha20"
local class = require "middleclass"

local Decryptor = class("Decryptor")

function Decryptor:initialize(key)
  self.key = key
  self.nonce = 0
end

function Decryptor:decrypt(ciphertext)
  local decrypted = chacha.decrypt(self.key:get(), 1, self:packedNonce(), ciphertext)
  self.nonce = self.nonce + 1

  return decrypted
end

-- Call f, but revert nonce if f raises an error
function Decryptor:transaction(f)
  local prev_nonce = self.nonce
  local is_succeed, err = pcall(f)

  if not is_succeed then
    self.nonce = prev_nonce
    error(err)
  end
end

function Decryptor:packedNonce()
  return "\x00\x00\x00\x00" .. string.pack("I8", self.nonce)
end

return Decryptor
