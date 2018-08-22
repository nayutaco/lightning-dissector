local class = require "middleclass"

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

return Reader
