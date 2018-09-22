package.path = os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?.lua;"
  .. os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?/init.lua;"
  .. package.path

local SecretCache = require("lightning-dissector.secret-cache")
local CompositeSecretFactory = require("lightning-dissector.secret-factory").CompositeSecretFactory
local PtarmSecretFactory = require("lightning-dissector.secret-factory").PtarmSecretFactory
local EclairSecretFactory = require("lightning-dissector.secret-factory").EclairSecretFactory
local PduAnalyzer = require "lightning-dissector.pdu-analyzer"

local protocol = Proto("LIGHTNING", "Lightning Network")
protocol.prefs.ptarmigan_key_paths = Pref.string("Ptarmigan key file", "~/.cache/ptarmigan/keys.log")
protocol.prefs.eclair_key_paths = Pref.string("Eclair log file", "~/.eclair/eclair.log")
protocol.prefs.note1 = Pref.statictext("You can specify multiple files by using : as separator, just like $PATH.")
protocol.prefs.note2 = Pref.statictext("Reload lightning-dissector by Shift+Ctrl+L to make changes take effect.")

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

local pdu_analyzer

function protocol.init()
  local secret_factories = {}

  for ptarmigan_key_path in protocol.prefs.ptarmigan_key_paths:gmatch("[^:]+") do
    table.insert(secret_factories, PtarmSecretFactory:new(ptarmigan_key_path))
  end

  for eclair_key_path in protocol.prefs.eclair_key_paths:gmatch("[^:]+") do
    table.insert(secret_factories, EclairSecretFactory:new(eclair_key_path))
  end

  pdu_analyzer = PduAnalyzer:new(SecretCache:new(CompositeSecretFactory:new(secret_factories)))
end

function protocol.dissector(buffer, pinfo, tree)
  pinfo.cols.protocol = "Lightning Network"

  local offset = pinfo.desegment_offset or 0
  while offset < buffer:len() do
    local analyzed_pdu = pdu_analyzer:analyze(pinfo, buffer(offset):tvb())

    if 0 < pinfo.desegment_len then
      pinfo.desegment_offset = offset
      debug(pinfo.desegment_len)
      return
    end

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
