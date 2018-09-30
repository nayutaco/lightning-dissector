local class = require "middleclass"
local bin = require "plc52.bin"
local inspect = require "inspect"
local Reader = require("lightning-dissector.utils").Reader

local InitDeserializer = class("InitDeserializer")

function InitDeserializer:initialize()
  self.number = 16
  self.name = "init"
end

function InitDeserializer:deserialize(payload)
  local defined_local_features = {
    [0] = "option_data_loss_protect",
    [1] = "option_data_loss_protect",
    [3] = "initial_routing_sync",
    [4] = "option_upfront_shutdown_script",
    [5] = "option_upfront_shutdown_script",
    [6] = "gossip_queries",
    [7] = "gossip_queries"
  }

  local reader = Reader:new(payload)

  local packed_gflen = reader:read(2)
  local gflen = string.unpack(">I2", packed_gflen)
  local packed_global_features = reader:read(gflen)
  local packed_lflen = reader:read(2)
  local lflen = string.unpack(">I2", packed_lflen)
  local packed_local_features = reader:read(lflen)
  local local_features = string.unpack(">I" .. lflen, packed_local_features)

  local optional_features = {}
  local required_features = {}
  for feature_id, feature_name in pairs(defined_local_features) do
    local lf_bits = lflen * 8
    local feature_mask = string.rep("0", lf_bits - feature_id - 1) .. "1" .. string.rep("0", feature_id)
    local is_feature_enabled = 0 < bit32.band(local_features, tonumber(feature_mask, 2))

    if is_feature_enabled then
      if feature_id % 2 == 1 then
        table.insert(optional_features, feature_name)
      else
        table.insert(required_features, feature_name)
      end
    end
  end

  return {
    gflen = {
      Raw = bin.stohex(packed_gflen),
      Deserialized = gflen
    },
    global_features = bin.stohex(packed_global_features),
    lflen = {
      Raw = bin.stohex(packed_lflen),
      Deserialized = lflen
    },
    local_features = {
      Raw = bin.stohex(packed_local_features),
      Deserialized = {
        Optional = inspect(optional_features),
        Required = inspect(required_features)
      }
    }
  }
end

return InitDeserializer
