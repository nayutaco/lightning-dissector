local class = require "middleclass"
local bin = require "plc52.bin"
local basexx = require "basexx"
local Reader = require "lightning-dissector.utils.reader"

NodeAnnouncementDeserializer = class("NodeAnnouncementDeserializer")

function NodeAnnouncementDeserializer:initialize()
  self.number = 257
  self.name = "node_announcement"
end

function NodeAnnouncementDeserializer:deserialize(payload)
  local reader = Reader:new(payload)

  local packed_signature = reader:read(64)
  local packed_flen = reader:read(2)
  local flen = string.unpack(">I2", packed_flen)
  local packed_features = reader:read(flen)
  local packed_timestamp = reader:read(4)
  local packed_node_id = reader:read(33)
  local packed_rgb_color = reader:read(3)
  local alias = reader:read(32)
  local packed_addrlen = reader:read(2)
  local addrlen = string.unpack(">I2", packed_addrlen)
  local packed_addresses = reader:read(addrlen)

  local timestamp = string.unpack(">I4", packed_timestamp)

  local r = string.unpack(">I1", packed_rgb_color:sub(1, 1))
  local g = string.unpack(">I1", packed_rgb_color:sub(2, 2))
  local b = string.unpack(">I1", packed_rgb_color:sub(3, 3))

  local addresses = {}
  local addresses_reader = Reader:new(packed_addresses)
  while not addresses_reader:is_finished() do
    local packed_address_type = addresses_reader:read(1)
    local address_type = string.unpack(">I1", packed_address_type)

    if address_type == 1 then
      local packed_ipv4_addr = addresses_reader:read(4)
      local packed_port = addresses_reader:read(2)

      local building_ipv4_addr = {}
      for i = 1, 4 do
        table.insert(string.unpack(">I1", packed_ipv4_addr:sub(i, i)))
      end

      local ipv4_addr = table.concat(building_ipv4_addr, ".")
      local port = string.unpack(">I2", packed_port)

      table.insert(addresses, {
        type = "IPv4",
        addr = ipv4_addr,
        port = port
      })
    elseif address_type == 2 then
      local packed_ipv6_addr = addresses_reader:read(16)
      local packed_port = addresses_reader:read(2)

      local building_ipv6_addr = {}
      for i = 1, 8, 2 do
        table.insert(bin.stohex(packed_ipv6_addr:sub(i, i + 1)))
      end

      local ipv6_addr = table.concat(building_ipv6_addr, ":")
      local port = string.unpack(">I2", packed_port)

      table.insert(addresses, {
        type = "IPv6",
        addr = ipv6_addr,
        port = port
      })
    elseif address_type == 3 then
      local packed_v2_onion_addr = addresses_reader:read(10)
      local v2_onion_addr = basexx.to_base32(packed_v2_onion_addr)
      local packed_port = addresses_reader:read(2)

      table.insert({
        type = "Tor v2 onion service",
        addr = v2_onion_addr .. ".onion",
        port = string.unpack(">I2", packed_port)
      })
    elseif address_type == 4 then
      local packed_v3_onion_addr = addresses_reader:read(32)
      local v3_onion_addr = basexx.to_base32(packed_v3_onion_addr)
      addresses_reader:read(3)  -- skip checksum
      local packed_port = addresses_reader:read(2)

      table.insert({
        type = "Tor v2 onion service",
        addr = v3_onion_addr .. ".onion",
        port = string.unpack(">I2", packed_port)
      })
    end
  end

  return {
    signature = bin.stohex(packed_signature),
    flen = {
      Raw = bin.stohex(packed_flen),
      Deserialized = flen
    },
    features = bin.stohex(packed_features),
    timestamp = {
      Raw = bin.stohex(packed_timestamp),
      Deserialized = timestamp
    },
    node_id = bin.stohex(packed_node_id),
    rgb_color = {
      Raw = bin.stohex(packed_rgb_color),
      Deserialized = {
        R = r,
        G = g,
        B = b
      }
    },
    alias = alias,
    addrlen = {
      Raw = bin.stohex(packed_addrlen),
      Deserialized = addrlen
    },
    addresses = {
      Raw = bin.stohex(packed_addresses),
      Deserialized = addresses
    }
  }
end

return NodeAnnouncementDeserializer
