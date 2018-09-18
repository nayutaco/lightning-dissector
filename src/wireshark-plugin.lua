package.path = os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?.lua;"
  .. os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?/init.lua;"
  .. package.path

local SecretCache = require("lightning-dissector.secret-manager").SecretCache
local CompositeSecretManager = require("lightning-dissector.secret-manager").CompositeSecretManager
local PtarmSecretManager = require("lightning-dissector.secret-manager").PtarmSecretManager
local EclairSecretManager = require("lightning-dissector.secret-manager").EclairSecretManager
local PduAnalyzer = require "lightning-dissector.pdu-analyzer"

local protocol = Proto("LIGHTNING", "Lightning Network")
protocol.prefs.ptarmigan_key_path = Pref.string("Ptarmigan key log file", "~/.cache/lightning-dissector/keys.log")
protocol.prefs.eclair_key_path = Pref.string("Eclair log file", "~/.eclair/eclair.log")
protocol.prefs.note = Pref.statictext("Restart Wireshark to let changes take effect.")

local pdu_analyzer = PduAnalyzer:new(
  SecretCache:new(
    CompositeSecretManager:new(
      PtarmSecretManager:new(protocol.prefs.ptarmigan_key_path),
      EclairSecretManager:new(protocol.prefs.eclair_key_path)
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

function protocol.dissector(buffer, pinfo, tree)
  pinfo.cols.protocol = "Lightning Network"

  local offset = 0
  while offset < buffer:len() do
    local analyzed_pdu = pdu_analyzer:analyze(pinfo, buffer(offset):tvb())

    -- TODO: Refactoring
    if analyzed_pdu.Length == nil then
      offset = buffer:len()
    else
      local header_length = 18
      local footer_length = 16
      offset = offset + header_length + analyzed_pdu.Length.Deserialized + footer_length
    end

    local subtree = tree:add(protocol, "Lightning Network")
    display(subtree, analyzed_pdu)
  end
end

DissectorTable.get("tcp.port"):add(9735, protocol)
