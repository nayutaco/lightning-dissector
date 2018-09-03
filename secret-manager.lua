local class = require "middleclass"
local bin = require "plc.bin"
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
  local host = pinfo.dst .. ":" .. pinfo.dst_port

  if self.secrets[host] ~= nil then
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
    debug("$LIGHTNINGKEYLOGFILE isn't set")
    return
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

local SecretManagers = class("SecretManagers", SecretManager)

function SecretManagers:initialize(secret_managers)
  self.secret_managers = secret_managers
end

function SecretManagers:find_secret(pinfo, buffer)
  for secret_manager in fun.iter(self.secret_managers) do
    local secret = secret_manager:find_secret(pinfo, buffer)

    if secret ~= nil then
      return secret
    end
  end
end

-- TODO:
local EclairSecretManager = class("EclairSecretManager", SecretManager)

return {
  SecretManagers = SecretManagers,
  KeyLogManager = KeyLogManager
}
