local class = require "middleclass"
local bin = require "plc52.bin"
local rex = require "rex_pcre"
local Secret = require "lightning-dissector.secret"
local constants = require "lightning-dissector.constants"

local SecretFactory = class("SecretFactory")

function SecretFactory:create(buffer)
  error("Not implemented")
end

local KeyLogSecretFactory = class("KeyLogSecretFactory", SecretFactory)

function KeyLogSecretFactory:initialize(log_path)
  self.log_path = rex.gsub(log_path, "^~", os.getenv("HOME"))
end

function KeyLogSecretFactory:create(buffer)
  local packed_length_mac = buffer:raw(constants.lengths.length, constants.lengths.length_mac)
  local length_mac = bin.stohex(packed_length_mac)

  -- First, assume nonce of the message is 0, and search key for the message
  local log_file = io.open(self.log_path)
  if log_file == nil then
    info('A preference "Key log file" refers to non-existent file')
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

local CompositeSecretFactory = class("CompositeSecretFactory", SecretFactory)

function CompositeSecretFactory:initialize(secret_factories)
  self.secret_factories = secret_factories
end

function CompositeSecretFactory:create(buffer)
  for _, secret_factory in ipairs(self.secret_factories) do
    local secret = secret_factory:create(buffer)

    if secret ~= nil then
      return secret
    end
  end
end

return {
  CompositeSecretFactory = CompositeSecretFactory,
  KeyLogSecretFactory = KeyLogSecretFactory
}
