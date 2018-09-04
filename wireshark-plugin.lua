local bin = require "plc.bin"
local SecretCache = require("lightning-dissector.secret-manager").SecretCache
local CompositeSecretManager = require("lightning-dissector.secret-manager").CompositeSecretManager
local KeyLogManager = require("lightning-dissector.secret-manager").KeyLogManager
local FrameAnalyzer = require "lightning-dissector.frame-analyzer"

local frame_analyzer = FrameAnalyzer:new(
  SecretCache:new(
    CompositeSecretManager:new(
      KeyLogManager:new()
    )
  )
)

local function display(tree, analyzed_frame)
  for key, value in pairs(analyzed_frame) do
    if type(value) == "table" then
      local subtree = tree:add(key .. ":")
      display(subtree, value)
    else
      tree:add(key .. ": " .. value)
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
  display(subtree, analyzed_frame)
end

DissectorTable.get("tcp.port"):add(9000, protocol)
