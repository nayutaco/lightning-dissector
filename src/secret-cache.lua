local class = require "middleclass"
local constants = require "lightning-dissector.constants"

local SecretCachePerPdu = class("SecretCachePerPdu")

function SecretCachePerPdu:initialize(secret_cache)
  self.secret_cache = secret_cache
  self.secrets = {}
end

function SecretCachePerPdu:find_or_create(pinfo, buffer)
  local length_mac = buffer:raw(constants.lengths.length, constants.lengths.length_mac)
  local secret_for_pdu = self.secrets[length_mac]

  if secret_for_pdu == "NOT FOUND" then
    return
  end

  if secret_for_pdu ~= nil then
    return secret_for_pdu:clone()
  end

  local secret_for_host = self.secret_cache:find_or_create(pinfo, buffer)
  if secret_for_host ~= nil then
    self.secrets[length_mac] = secret_for_host:clone()
    return secret_for_host
  end

  self.secrets[length_mac] = "NOT FOUND"
end

function SecretCachePerPdu:delete(cache_key)
  self.secrets[cache_key] = nil
end

local SecretCachePerHost = class("SecretCachePerHost")

function SecretCachePerHost:initialize(secret_factory)
  self.secret_factory = secret_factory
  self.secrets = {}
end

function SecretCachePerHost:find_or_create(pinfo, buffer)
  local host = tostring(pinfo.dst) .. ":" .. pinfo.dst_port

  if self.secrets[host] ~= nil and 1000 > self.secrets[host].nonce then
    return self.secrets[host]
  end

  local secret = self.secret_factory:create(buffer)
  if secret ~= nil then
    self.secrets[host] = secret
    return self.secrets[host]
  end
end

return {
  SecretCachePerPdu = SecretCachePerPdu,
  SecretCachePerHost = SecretCachePerHost
}
