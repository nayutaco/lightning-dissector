local class = require "middleclass"

-- provides file-like read
local Reader = class("Reader")

function Reader:initialize(payload)
  self.payload = payload
  self.untouched = true
  self.offset = 0
end

function Reader:read(how_many)
  if self.untouched then
    self.untouched = false
  else
    self.offset = self.offset + how_many
  end

  return self.payload:sub(self.offset + 1, self.offset + how_many)
end

return Reader
