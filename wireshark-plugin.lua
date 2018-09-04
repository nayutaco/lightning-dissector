local bin = require "plc.bin"
local SecretManagers = require("lightning-dissector.secret-manager").SecretManagers
local KeyLogManager = require("lightning-dissector.secret-manager").KeyLogManager
local FrameAnalyzer = require "lightning-dissector.frame-analyzer"

local secret_manager = SecretManagers:new(
  KeyLogManager:new()
  -- TODO: Add EclairSecretManager
)
local frame_analyzer = FrameAnalyzer:new(secret_manager)

function find_deserializer_for(type)
  local deserializers = {
    require("lightning-dissector.deserializers.init"):new(),
    require("lightning-dissector.deserializers.ping"):new(),
    require("lightning-dissector.deserializers.pong"):new(),
    require("lightning-dissector.deserializers.error"):new()
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

  local analyzed_frame = frame_analyzer:analyze(pinfo, buffer)

  local subtree = tree:add(protocol, "Lightning Network")

  local secret_tree = subtree:add("Secret:")
  secret_tree:add("Key: " .. bin.stohex(analyzed_frame.packed_key))
  secret_tree:add("Nonce: " .. bin.stohex(analyzed_frame.packed_nonce))

  local length_tree = subtree:add("Length:")
  length_tree:add("Encrypted: " .. bin.stohex(analyzed_frame.packed_encrypted_len))
  length_tree:add("Decrypted: " .. bin.stohex(analyzed_frame.packed_decrypted_len))
  length_tree:add("Deserialized: " .. string.unpack(">I2", analyzed_frame.packed_decrypted_len))

  local message_tree = subtree:add("Message:")
  message_tree:add("Encrypted: " .. bin.stohex(analyzed_frame.packed_encrypted_msg))
  message_tree:add("Decrypted: " .. bin.stohex(analyzed_frame.packed_decrypted_msg))
  local deserialized_tree = message_tree:add("Deserialized")

  local type = string.unpack(">I2", analyzed_frame.packed_decrypted_msg:sub(1, 2))
  local payload = analyzed_frame.packed_decrypted_msg:sub(3)
  local deserializer = find_deserializer_for(type)
  local deserialized = deserializer:deserialize(payload)

  deserialized_tree:add("type: " .. deserializer.name)

  for key, value in pairs(deserialized) do
    deserialized_tree:add(key .. ": " .. value)
  end
end

DissectorTable.get("tcp.port"):add(9000, protocol)
