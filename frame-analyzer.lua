local class = require "middleclass"

local FrameAnalyzer = class("FrameAnalyzer")

function FrameAnalyzer:initialize(secret_manager)
  self.secret_manager = secret_manager
  self.analyzed_frames = {}
end

function FrameAnalyzer:analyze(pinfo, buffer)
  if self.analyzed_frames[pinfo.number] == nil then
    self.analyzed_frames[pinfo.number] = self:_analyze(pinfo, buffer)
  end

  return self.analyzed_frames[pinfo.number]
end

function FrameAnalyzer:_analyze(pinfo, buffer)
  local secret = self.secret_manager:find_secret(pinfo, buffer)
  if secret == nil then
    error("key/nonce not found")
  end

  local packed_encrypted_len = buffer():raw(0, 2)
  local packed_len_mac = buffer():raw(2, 16)
  local packed_decrypted_len = secret:decrypt(packed_encrypted_len, packed_len_mac)
  local decrypted_len = string.unpack(">I2", packed_decrypted_len)

  local packed_encrypted_msg = buffer:raw(18, decrypted_len)
  local packed_msg_mac = buffer:raw(18 + decrypted_len)
  local packed_decrypted_msg = secret:decrypt(packed_encrypted_msg, packed_msg_mac)

  return {
    packed_key = secret:packed_key(),
    packed_nonce = secret:packed_nonce(),
    packed_encrypted_len = packed_encrypted_len,
    packed_decrypted_len = packed_decrypted_len,
    packed_encrypted_msg = packed_encrypted_msg,
    packed_decrypted_msg = packed_decrypted_msg
  }
end

return FrameAnalyzer
