local class = require "middleclass"
local bin = require "plc.bin"
local fun = require "fun"
local rex = require "rex_pcre"
local Secret = require "lightning-dissector.secret"

-- just an interface
local SecretManager = class("SecretManager")

function SecretManager:find_secret(pinfo, buffer)
  error("Not implemented")
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
    debug("$LIGHTNINGKEYLOGFILE refers to non-existent file")
    return
  end

  local log = log_file:read("*all")
  log_file:close()

  local key = rex.match(log, mac .. " ([0-9a-f]+)")
  if key == nil then
    debug("Encountered nonce=0 message, but the new key not found")
    return
  end

  return bin.hextos(key)
end

local CompositeSecretManager = class("CompositeSecretManager", SecretManager)

function CompositeSecretManager:initialize(...)
  self.secret_managers = table.pack(...)
end

function CompositeSecretManager:find_secret(pinfo, buffer)
  for _, secret_manager in fun.iter(self.secret_managers) do
    return secret_manager:find_secret(pinfo, buffer)
  end
end

local SecretCache = class("SecretCache", SecretManager)

function SecretCache:initialize(secret_manager)
  self.secret_manager = secret_manager
  self.secrets = {}
end

function SecretCache:find_secret(pinfo, buffer)
  if self.secrets[pinfo.number] ~= nil then
    return self.secrets[pinfo.number]:clone()
  end

  local new_secret = self.secret_manager:find_secret(pinfo, buffer)
  if new_secret == nil then
    error("key/nonce not found")
  end

  self.secrets[pinfo.number] = new_secret:clone()
  return new_secret
end

-- TODO:
local EclairSecretManager = class("EclairSecretManager", SecretManager)

return {
  SecretCache = SecretCache,
  CompositeSecretManager = CompositeSecretManager,
  KeyLogManager = KeyLogManager
}
