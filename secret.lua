local class = require "middleclass"

local Secret = class("Secret")

function Secret:initialize(packed_key)
  self._packed_key = key  -- readonly
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

function Secret:increment_nonce()
  self.nonce = self.nonce + 1
end

return Secret
