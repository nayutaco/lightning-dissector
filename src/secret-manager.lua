local class = require "middleclass"
local bin = require "plc52.bin"
local rex = require "rex_pcre"
local Secret = require "lightning-dissector.secret"

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

  local secret = self:renew_secret(buffer)
  if secret == nil then
    return
  end

  self.secrets[host] = secret
  return self.secrets[host]
end

function KeyLogManager:renew_secret(buffer)
  error("Not implemented")
end

local PtarmSecretManager = class("PtarmSecretManager", KeyLogManager)

function PtarmSecretManager:initialize(log_path)
  KeyLogManager.initialize(self)
  self.log_path = rex.gsub(log_path, "^~", os.getenv("HOME"))
end

function PtarmSecretManager:renew_secret(buffer)
  local packed_length_mac = buffer:raw(2, 16)
  local length_mac = bin.stohex(packed_length_mac)

  -- First, assume nonce of the message is 0, and search key for the message
  local log_file = io.open(self.log_path)
  if log_file == nil then
    critical("$LIGHTNINGKEYLOGFILE refers to non-existent file")
    return
  end

  local log = log_file:read("*all")
  log_file:close()

  local key = rex.match(log, length_mac .. " ([0-9a-f]+)")
  if key ~= nil then
    local packed_key = bin.hextos(key)
    return Secret:new(packed_key)
  end
end

local EclairSecretManager = class("EclairSecretManager", KeyLogManager)

function EclairSecretManager:initialize(log_path)
  KeyLogManager.initialize(self)
  self.log_path = rex.gsub(log_path, "^~", os.getenv("HOME"))
end

function EclairSecretManager:renew_secret(buffer)
  local packed_length_mac = buffer:raw(2, 16)
  local length_mac = bin.stohex(packed_length_mac)

  local log_file = io.open(self.log_path)
  if log_file == nil then
    critical("$ECLAIRLOGFILE refers to non-existent file")
    return
  end

  -- FIXME: This line causes wireshark freeze if the log is big
  local log = log_file:read("*all")
  log_file:close()

  local pattern = "encrypt\\(([0-9a-f]+), ([0-9a-f]+), .+ = .+"
    .. length_mac
    .. "\\)|decrypt\\(([0-9a-f]+), ([0-9a-f]+), .+, "
    .. length_mac
    .. "\\) ="
  local sk, sn, rk, rn = rex.match(log, pattern)
  local key = sk or rk
  local nonce_hex = sn or rn

  if key and nonce_hex then
    local packed_key = bin.hextos(key)
    local packed_nonce = bin.hextos(nonce_hex:sub(9))
    local nonce = string.unpack("I8", packed_nonce)

    return Secret:new(packed_key, nonce)
  end
end

local CompositeSecretManager = class("CompositeSecretManager", SecretManager)

function CompositeSecretManager:initialize(secret_managers)
  self.secret_managers = secret_managers
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

return {
  SecretCache = SecretCache,
  CompositeSecretManager = CompositeSecretManager,
  PtarmSecretManager = PtarmSecretManager,
  EclairSecretManager = EclairSecretManager
}
