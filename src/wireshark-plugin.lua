package.path = os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?.lua;"
  .. os.getenv("HOME")
  .. "/.luarocks/share/lua/5.2/?/init.lua;"
  .. package.path

local SecretCache = require("lightning-dissector.secret-cache").SecretCache
local SecretTable = require("lightning-dissector.secret-cache").SecretTable
local CompositeSecretFactory = require("lightning-dissector.secret-factory").CompositeSecretFactory
local KeyLogSecretFactory = require("lightning-dissector.secret-factory").KeyLogSecretFactory
local EclairSecretFactory = require("lightning-dissector.secret-factory").EclairSecretFactory
local pdu_analyzer = require "lightning-dissector.pdu-analyzer"
local constants = require "lightning-dissector.constants"
local OrderedDict = require("lightning-dissector.utils").OrderedDict

local protocol = Proto("LIGHTNING", "Lightning Network")
protocol.prefs.key_log_paths = Pref.string("Key log file", "~/.cache/ptarmigan/keys.log")
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

  for key_log_path in protocol.prefs.key_log_paths:gmatch("[^:]+") do
    table.insert(secret_factories, KeyLogSecretFactory:new(key_log_path))
  end

  for eclair_key_path in protocol.prefs.eclair_key_paths:gmatch("[^:]+") do
    table.insert(secret_factories, EclairSecretFactory:new(eclair_key_path))
  end

  secret_cache = SecretCache:new(SecretTable:new(CompositeSecretFactory:new(secret_factories)))
end

function protocol.dissector(buffer, pinfo, tree)
  pinfo.cols.protocol = "Lightning Network"

  -- When a TCP segment contains multiple lightning messages, offset represents where a next lightning message starts.
  local offset = pinfo.desegment_offset or 0
  -- Until we analyze all lightning messages in a TCP segment
  while offset < buffer:len() do
    local pdu_buffer = buffer(offset):tvb()
    local analyzed_pdu = OrderedDict:new()

    local secret = secret_cache:find_or_create(pinfo, pdu_buffer)
    if secret == nil then
      analyzed_pdu:append("Note", "Decryption key not found. maybe still in handshake phase.")
      -- Finish the while loop.
      offset = buffer:len()
    else
      local secret_before_decryption = secret:clone()

      local payload_length = pdu_analyzer.analyze_length(pdu_buffer, secret)
      local whole_length = constants.lengths.header + payload_length.deserialized + constants.lengths.footer
      -- When a lightning message is split across TCP segments
      if whole_length > pdu_buffer():len() then
        -- If cache exists, secret_cache:find_or_create returns freezed Secret,
        -- which means we cannot increment its nonce.
        -- So we have to clear the cache.
        secret_cache:delete(payload_length.packed_mac)
        secret.nonce = secret_before_decryption.nonce
        -- Tell Wireshark how many more bytes we need to complete a lightning message.
        pinfo.desegment_len = whole_length - pdu_buffer():len()
        -- When a TCP segment contains multiple lightning message and last one is split across TCP segments,
        -- we need to store where the lightning message starts for next dissector call.
        pinfo.desegment_offset = offset
        -- Terminate current dissector call, and retry when a next TCP segment comes.
        return
      end

      local payload_buffer =
        pdu_buffer(constants.lengths.header, payload_length.deserialized + constants.lengths.footer):tvb()
      local payload = pdu_analyzer.analyze_payload(payload_buffer, secret)

      analyzed_pdu:append("Secret", secret:display())
      analyzed_pdu:append("Length", payload_length.display())
      analyzed_pdu:append("Payload", payload.display())
      offset = offset + whole_length
    end

    local subtree = tree:add(protocol, "Lightning Network")
    display(subtree, analyzed_pdu)
  end
end

DissectorTable.get("tcp.port"):add(9735, protocol)
