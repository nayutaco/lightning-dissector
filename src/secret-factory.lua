local class = require "middleclass"
local bin = require "plc52.bin"
local rex = require "rex_pcre"
local Secret = require "lightning-dissector.secret"

local SecretFactory = class("SecretFactory")

function SecretFactory:find_or_create(pinfo, buffer)
  error("Not implemented")
end

local KeyLogManager = class("KeyLogManager", SecretFactory)

function KeyLogManager:initialize()
  self.secrets = {}
end

function KeyLogManager:find_or_create(pinfo, buffer)
  local host = tostring(pinfo.dst) .. ":" .. pinfo.dst_port

  if self.secrets[host] ~= nil and 1000 > self.secrets[host]:nonce() then
    return self.secrets[host]
  end

  local secret = self:create(buffer)
  if secret == nil then
    return
  end

  self.secrets[host] = secret
  return self.secrets[host]
end

function KeyLogManager:create(buffer)
  error("Not implemented")
end

local PtarmSecretFactory = class("PtarmSecretFactory", KeyLogManager)

function PtarmSecretFactory:initialize(log_path)
  KeyLogManager.initialize(self)
  self.log_path = rex.gsub(log_path, "^~", os.getenv("HOME"))
end

function PtarmSecretFactory:create(buffer)
  local packed_length_mac = buffer:raw(2, 16)
  local length_mac = bin.stohex(packed_length_mac)

  -- First, assume nonce of the message is 0, and search key for the message
  local log_file = io.open(self.log_path)
  if log_file == nil then
    info('A preference "Ptarmigan key file" refers to non-existent file')
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

local EclairSecretFactory = class("EclairSecretFactory", KeyLogManager)

function EclairSecretFactory:initialize(log_path)
  KeyLogManager.initialize(self)
  self.log_path = rex.gsub(log_path, "^~", os.getenv("HOME"))
end

function EclairSecretFactory:create(buffer)
  local packed_length_mac = buffer:raw(2, 16)
  local length_mac = bin.stohex(packed_length_mac)

  local log_file = io.open(self.log_path)
  if log_file == nil then
    info('A preference "Eclair log file" refers to non-existent file')
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

local CompositeSecretFactory = class("CompositeSecretFactory", SecretFactory)

function CompositeSecretFactory:initialize(secret_factories)
  self.secret_factories = secret_factories
end

function CompositeSecretFactory:find_or_create(pinfo, buffer)
  for _, secret_factory in ipairs(self.secret_factories) do
    local secret = secret_factory:find_or_create(pinfo, buffer)

    if secret ~= nil then
      return secret
    end
  end
end

return {
  CompositeSecretFactory = CompositeSecretFactory,
  PtarmSecretFactory = PtarmSecretFactory,
  EclairSecretFactory = EclairSecretFactory
}
