package.path = os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?.lua;"
  .. os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?/init.lua;"
  .. package.path

local SecretCachePerPdu = require("lightning-dissector.secret-cache").SecretCachePerPdu
local SecretCachePerHost = require("lightning-dissector.secret-cache").SecretCachePerHost
local CompositeSecretFactory = require("lightning-dissector.secret-factory").CompositeSecretFactory
local PtarmSecretFactory = require("lightning-dissector.secret-factory").PtarmSecretFactory
local EclairSecretFactory = require("lightning-dissector.secret-factory").EclairSecretFactory
local pdu_analyzer = require "lightning-dissector.pdu-analyzer"
local constants = require "lightning-dissector.constants"

local protocol = Proto("LIGHTNING", "Lightning Network")
protocol.prefs.ptarmigan_key_paths = Pref.string("Ptarmigan key file", "~/.cache/ptarmigan/keys.log")
protocol.prefs.eclair_key_paths = Pref.string("Eclair log file", "~/.eclair/eclair.log")
protocol.prefs.note1 = Pref.statictext("You can specify multiple files by using : as separator, just like $PATH.")
protocol.prefs.note2 = Pref.statictext("Reload lightning-dissector by Shift+Ctrl+L to make changes take effect.")

local function display(tree, analyzed_pdu)
  for key, value in pairs(analyzed_pdu) do
    if type(value) == "table" then
      local subtree = tree:add(key .. ":")
      display(subtree, value)
    else
      tree:add(key .. ": " .. value)
    end
  end
end

local secret_cache

function protocol.init()
  local secret_factories = {}

  for ptarmigan_key_path in protocol.prefs.ptarmigan_key_paths:gmatch("[^:]+") do
    table.insert(secret_factories, PtarmSecretFactory:new(ptarmigan_key_path))
  end

  for eclair_key_path in protocol.prefs.eclair_key_paths:gmatch("[^:]+") do
    table.insert(secret_factories, EclairSecretFactory:new(eclair_key_path))
  end

  secret_cache = SecretCachePerPdu:new(SecretCachePerHost:new(CompositeSecretFactory:new(secret_factories)))
end

function protocol.dissector(buffer, pinfo, tree)
  pinfo.cols.protocol = "Lightning Network"

  local offset = pinfo.desegment_offset or 0
  while offset < buffer:len() do
    local pdu_buffer = buffer(offset):tvb()
    local analyzed_pdu = {}

    local secret = secret_cache:find_or_create(pinfo, pdu_buffer)
    if secret == nil then
      analyzed_pdu.Note = "Decryption key not found. maybe still in handshake phase."
      offset = buffer:len()
    else
      local secret_before_decryption = secret:clone()

      local payload_length = pdu_analyzer.analyze_length(pdu_buffer, secret)
      local whole_length = constants.lengths.header + payload_length.deserialized + constants.lengths.footer
      if whole_length > pdu_buffer():len() then
        secret_cache:delete(payload_length.packed_mac)
        secret.nonce = secret_before_decryption.nonce
        pinfo.desegment_len = whole_length - pdu_buffer():len()
        pinfo.desegment_offset = offset
        return
      end

      local payload_buffer =
        pdu_buffer(constants.lengths.header, payload_length.deserialized + constants.lengths.footer):tvb()
      local payload = pdu_analyzer.analyze_payload(payload_buffer, secret)

      analyzed_pdu.Secret = secret:display()
      analyzed_pdu.Length = payload_length.display()
      analyzed_pdu.Payload = payload.display()
      offset = offset + whole_length
    end

    local subtree = tree:add(protocol, "Lightning Network")
    display(subtree, analyzed_pdu)
  end
end

DissectorTable.get("tcp.port"):add(9735, protocol)
