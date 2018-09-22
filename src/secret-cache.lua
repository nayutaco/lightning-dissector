local class = require "middleclass"

local SecretCache = class("SecretCache")

function SecretCache:initialize(secret_manager)
  self.secret_manager = secret_manager
  self.secrets = {}
end

function SecretCache:find_or_create(pinfo, buffer)
  local length_mac = buffer:raw(2, 16)
  local secret_for_pdu = self.secrets[length_mac]

  if secret_for_pdu == "NOT FOUND" then
    return
  end

  if secret_for_pdu ~= nil then
    return secret_for_pdu:clone()
  end

  local secret_for_node = self.secret_manager:find_secret(pinfo, buffer)
  if secret_for_node ~= nil then
    self.secrets[length_mac] = secret_for_node:clone()
    return secret_for_node
  end

  self.secrets[length_mac] = "NOT FOUND"
end

return SecretCache
