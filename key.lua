local class = require "middleclass"
local rex = require "rex_pcre"
local bin = require "plc.bin"

-- abstract
local Key = class("Key")

function Key:initialize(is_for_send)
  self.is_for_send = is_for_send
end

local PtarmKey = class("PtarmKey", Key)

function PtarmKey:refresh()
  if self.packed == nil then
    local f = io.open(os.getenv("HOME") .. "/.cache/ptarmigan/debug.log")
    local log = f:read("*all")
    f:close()

    local key_name
    if self.is_for_send then
      key_name = "sk"
    else
      key_name = "rk"
    end

    local key = rex.match(log, key_name .. ": (.+)")
    self.packed = bin.hextos(key)
  end
end

function PtarmKey:get()
  if self.packed == nil then
    self:refresh()
  end

  return self.packed
end

return {
  Key = Key,
  PtarmKey = PtarmKey
}
