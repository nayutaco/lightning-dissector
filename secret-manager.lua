local class = require "middleclass"
local bin = require "plc.bin"
local rex = require "rex_pcre"
local Secret = require "lightning-dissector.secret"

local SecretManager = class("SecretManager")

function SecretManager:find_secret(pinfo, buffer)
  error("Not implemented")
end

function SecretManager:find_secret_or_abort(pinfo, buffer)
  local secret = self:find_secret(pinfo, buffer)

  if secret == nil then
    error("key/nonce not found")
  end

  return secret
end

local KeyLogManager = class("KeyLogManager", SecretManager)

function KeyLogManager:initialize()
  self.secrets = {}
end

function KeyLogManager:find_secret(pinfo, buffer)
  local host = tostring(pinfo.dst) .. ":" .. pinfo.dst_port

  if self.secrets[host] ~= nil and 1000 > self.secrets[host]:nonce() then
    return self.secrets[host]
  end

  local packed_length_mac = buffer:raw(2, 16)
  local packed_key = self:find_packed_key(packed_length_mac)

  if packed_key == nil then
    return
  end

  self.secrets[host] = Secret:new(packed_key)
  return self.secrets[host]
end

function KeyLogManager:find_packed_key(packed_mac)
  local mac = bin.stohex(packed_mac)

  local log_path = os.getenv("LIGHTNINGKEYLOGFILE")
  if log_path == nil then
    log_path = os.getenv("HOME") .. "/.cache/lightning-dissector/keys.log"
  end

  local log_file = io.open(log_path)
  if log_file == nil then
    critical("$LIGHTNINGKEYLOGFILE refers to non-existent file")
    return
  end

  local log = log_file:read("*all")
  log_file:close()

  local key = rex.match(log, mac .. " ([0-9a-f]+)")
  if key == nil then
    warn("Encountered nonce=0 message, but the new key not found. Still in handshake phase?")
    return
  end

  return bin.hextos(key)
end

local CompositeSecretManager = class("CompositeSecretManager", SecretManager)

function CompositeSecretManager:initialize(...)
  self.secret_managers = table.pack(...)
end

function CompositeSecretManager:find_secret(pinfo, buffer)
  for _, secret_manager in ipairs(self.secret_managers) do
    local secret = secret_manager:find_secret(pinfo, buffer)
  
    if secret ~= nil then
      return secret
    end
  end
end

local SecretCache = class("SecretCache", SecretManager)

function SecretCache:initialize(secret_manager)
  self.secret_manager = secret_manager
  self.secrets = {}
end

function SecretCache:find_secret(pinfo, buffer)
  local length_mac = buffer:raw(2, 16)

  local secret_for_pdu = self.secrets[length_mac]
  if secret_for_pdu ~= nil then
    return secret_for_pdu:clone()
  end

  local secret_for_node = self.secret_manager:find_secret(pinfo, buffer)
  if secret_for_node ~= nil then
    self.secrets[length_mac] = secret_for_node:clone()
    return secret_for_node
  end
end

-- TODO:
local EclairSecretManager = class("EclairSecretManager", SecretManager)

return {
  SecretCache = SecretCache,
  CompositeSecretManager = CompositeSecretManager,
  KeyLogManager = KeyLogManager
}
