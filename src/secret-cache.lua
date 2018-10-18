local class = require "middleclass"
local constants = require "lightning-dissector.constants"

-- Wireshark calls dissector when 1) TCP segment comes 2) TCP segment get clicked,
-- so we have to store Secret state at the time of 1 and reuse it when 2.
-- This class does that.
local SecretCache = class("SecretCache")

function SecretCache:initialize(secret_table)
  self.secret_table = secret_table
  self.secrets = {}
end

function SecretCache:find_or_create(pinfo, buffer)
  local length_mac = buffer:raw(constants.lengths.length, constants.lengths.length_mac)
  local secret_for_pdu = self.secrets[length_mac]

  if secret_for_pdu == "NOT FOUND" then
    return
  end

  if secret_for_pdu ~= nil then
    -- We return cloned one because Secret:decrypt should not mutate internal state of SecretCache.
    return secret_for_pdu:clone()
  end

  local secret_for_host = self.secret_table:find_or_create(pinfo, buffer)
  if secret_for_host ~= nil then
    -- We store cloned one because Secret:decrypt should not mutate internal state of SecretCache.
    self.secrets[length_mac] = secret_for_host:clone()
    return secret_for_host
  end

  self.secrets[length_mac] = "NOT FOUND"
end

function SecretCache:delete(cache_key)
  self.secrets[cache_key] = nil
end

-- Secret manages nonce so Secret should be instantiated per host.
-- This class does that.
local SecretTable = class("SecretTable")

function SecretTable:initialize(secret_factory)
  self.secret_factory = secret_factory
  self.secrets = {}
end

function SecretTable:find_or_create(pinfo, buffer)
  local host = tostring(pinfo.dst) .. ":" .. pinfo.dst_port

  if self.secrets[host] ~= nil and 1000 > self.secrets[host].nonce then
    return self.secrets[host]
  end

  -- When cache not hit or nonce exceeds 1000, instantiate new Secret.
  local secret = self.secret_factory:create(buffer)
  if secret ~= nil then
    self.secrets[host] = secret
    return self.secrets[host]
  end
end

return {
  SecretCache = SecretCache,
  SecretTable = SecretTable
}
