local class = require "middleclass"

local FrameAnalyzer = class("FrameAnalyzer")

function FrameAnalyzer:initialize(decryptor)
  self.decryptor = decryptor
  self.analyzed_frames = {}
end

function FrameAnalyzer:analyze(buffer, pinfo)
  if self.analyzed_frames[pinfo.number] == nil then
    self.analyzed_frames[pinfo.number] = self:_analyze(buffer)
  end

  return self.analyzed_frames[pinfo.number]
end

function FrameAnalyzer:_analyze(buffer)
  local packed_encrypted_len
  local packed_decrypted_len
  local packed_encrypted_msg
  local packed_decrypted_msg
  self.decryptor:transaction(function()
    packed_encrypted_len = buffer():raw(0, 2)
    packed_decrypted_len = self.decryptor:decrypt(packed_encrypted_len)
    local decrypted_len = string.unpack(">I2", packed_decrypted_len)

    -- if out of range occurs here, key/nonce may be incorrect
    packed_encrypted_msg = buffer():raw(18, decrypted_len)
    packed_decrypted_msg = self.decryptor:decrypt(packed_encrypted_msg)
  end)

  local INIT = 16
  local type = string.unpack(">I2", packed_decrypted_msg:sub(1, 2))
  if type == 16 then
    self.decryptor.nonce = 2
  elseif self.decryptor.nonce == 2 then  -- This means it's in handshake phase
    self.decryptor.nonce = 0
  end

  return {
    packed_key = self.decryptor.key:get(),
    packed_nonce = self.decryptor:packedNonce(),
    packed_encrypted_len = packed_encrypted_len,
    packed_decrypted_len = packed_decrypted_len,
    packed_encrypted_msg = packed_encrypted_msg,
    packed_decrypted_msg = packed_decrypted_msg
  }
end

return FrameAnalyzer
