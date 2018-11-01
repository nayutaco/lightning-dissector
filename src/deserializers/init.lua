local bin = require "plc52.bin"
local inspect = require "inspect"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local deserialize_flags = require("lightning-dissector.utils").deserialize_flags
local fields = require("lightning-dissector.constants").fields

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_gflen = reader:read(2)
  local gflen = string.unpack(">I2", packed_gflen)
  local packed_global_features = reader:read(gflen)
  local packed_lflen = reader:read(2)
  local lflen = string.unpack(">I2", packed_lflen)
  local packed_local_features = reader:read(lflen)

  return OrderedDict:new(
    "gflen", OrderedDict:new(
      fields.payload.deserialized.gflen.raw, bin.stohex(packed_gflen),
      fields.payload.deserialized.gflen.deserialized, gflen
    ),
    fields.payload.deserialized.global_features, bin.stohex(packed_global_features),
    "lflen", OrderedDict:new(
      fields.payload.deserialized.lflen.raw, bin.stohex(packed_lflen),
      fields.payload.deserialized.lflen.deserialized, lflen
    ),
    "local_features", OrderedDict:new(
      fields.payload.deserialized.local_features.raw, bin.stohex(packed_local_features),
      "Deserialized", OrderedDict:new(
        fields.payload.deserialized.local_features.deserialized.optional, inspect(deserialize_flags(packed_local_features, {
          [2] = "option_data_loss_protect",
          [4] = "initial_routing_sync",
          [6] = "option_upfront_shutdown_script",
          [8] = "gossip_queries"
        })),
        fields.payload.deserialized.local_features.deserialized.required, inspect(deserialize_flags(packed_local_features, {
          [1] = "option_data_loss_protect",
          [5] = "option_upfront_shutdown_script",
          [7] = "gossip_queries",
        }))
      )
    )
  )
end

return {
  number = 16,
  name = "init",
  deserialize = deserialize
}
