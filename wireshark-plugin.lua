local bin = require "plc.bin"
local key = require "lightning-dissector.key"
local Decryptor = require "lightning-dissector.decryptor"
local FrameAnalyzer = require "lightning-dissector.frame-analyzer"

local key_for_send = key.PtarmKey:new(true)
local decryptor_for_send = Decryptor:new(key_for_send)
local frame_analyzer = FrameAnalyzer:new(decryptor_for_send)

function find_deserializer_for(type)
  local deserializers = {
    require("lightning-dissector.deserializers.init"):new(),
    require("lightning-dissector.deserializers.ping"):new()
  }

  for _, deserializer in pairs(deserializers) do
    if deserializer.number == type then
      return deserializer
    end
  end
end

local protocol = Proto("lightning", "Lightning Network")
function protocol.dissector(buffer, pinfo, tree)
  if pinfo.dst_port ~= 9000 then
    return
  end

  pinfo.cols.protocol = "Lightning Network"

  local analyzed_frame = frame_analyzer:analyze(buffer, pinfo)

  local subtree = tree:add(protocol, buffer(), "Lightning Network")
  subtree:add("key: " .. bin.stohex(analyzed_frame.packed_key))
  subtree:add("nonce: " .. bin.stohex(analyzed_frame.packed_nonce))
  subtree:add("encrypted_len: " .. bin.stohex(analyzed_frame.packed_encrypted_len))
  subtree:add("decrypted_len: " .. bin.stohex(analyzed_frame.packed_decrypted_len))
  subtree:add("encrypted_msg: " .. bin.stohex(analyzed_frame.packed_encrypted_msg))
  subtree:add("decrypted_msg: " .. bin.stohex(analyzed_frame.packed_decrypted_msg))

  local type = string.unpack(">I2", analyzed_frame.packed_decrypted_msg:sub(1, 2))
  local payload = analyzed_frame.packed_decrypted_msg:sub(3)
  local deserializer = find_deserializer_for(type)
  local deserialized = deserializer:deserialize(payload)

  subtree:add("type: " .. deserializer.name)

  for key, value in pairs(deserialized) do
    subtree:add(key .. ": " .. value)
  end
end

DissectorTable.get("tcp.port"):add(9000, protocol)
