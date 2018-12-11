package = "lightning-dissector"
version = "scm-1"

source = {
  url = "git://github.com/nayutaco/lightning-dissector.git"
}

description = {
  summary = "A wireshark plugin to analyze communication between lightning network nodes",
  homepage = "https://github.com/nayutaco/lightning-dissector",
  license = "MIT"
}

dependencies = { 
  "lua == 5.2",
  "lrexlib-pcre == 2.9.0",
  "compat53 == 0.7",
  "inspect == 3.1.1",
  "basexx == 0.4.0",
  "poly1305 == 1.0",
  "middleclass == 4.1.1",
  "lua-zlib == 1.2"
}

build = {
  type = "builtin",
  modules = {
    ["lightning-dissector.wireshark-plugin"] = "src/wireshark-plugin.lua",
    ["lightning-dissector.pdu-analyzer"] = "src/pdu-analyzer.lua",
    ["lightning-dissector.secret"] = "src/secret.lua",
    ["lightning-dissector.secret-factory"] = "src/secret-factory.lua",
    ["lightning-dissector.secret-cache"] = "src/secret-cache.lua",
    ["lightning-dissector.constants"] = "src/constants.lua",
    ["lightning-dissector.deserializers.init"] = "src/deserializers/init.lua",
    ["lightning-dissector.deserializers.ping"] = "src/deserializers/ping.lua",
    ["lightning-dissector.deserializers.pong"] = "src/deserializers/pong.lua",
    ["lightning-dissector.deserializers.error"] = "src/deserializers/error.lua",
    ["lightning-dissector.deserializers.channel-announcement"] = "src/deserializers/channel-announcement.lua",
    ["lightning-dissector.deserializers.channel-update"] = "src/deserializers/channel-update.lua",
    ["lightning-dissector.deserializers.node-announcement"] = "src/deserializers/node-announcement.lua",
    ["lightning-dissector.deserializers.open-channel"] = "src/deserializers/open-channel.lua",
    ["lightning-dissector.deserializers.accept-channel"] = "src/deserializers/accept-channel.lua",
    ["lightning-dissector.deserializers.funding-created"] = "src/deserializers/funding-created.lua",
    ["lightning-dissector.deserializers.channel-reestablish"] = "src/deserializers/channel-reestablish.lua",
    ["lightning-dissector.deserializers.funding-signed"] = "src/deserializers/funding-signed.lua",
    ["lightning-dissector.deserializers.funding-locked"] = "src/deserializers/funding-locked.lua",
    ["lightning-dissector.deserializers.shutdown"] = "src/deserializers/shutdown.lua",
    ["lightning-dissector.deserializers.closing-signed"] = "src/deserializers/closing-signed.lua",
    ["lightning-dissector.deserializers.update-add-htlc"] = "src/deserializers/update-add-htlc.lua",
    ["lightning-dissector.deserializers.update-fulfill-htlc"] = "src/deserializers/update-fulfill-htlc.lua",
    ["lightning-dissector.deserializers.update-fail-htlc"] = "src/deserializers/update-fail-htlc.lua",
    ["lightning-dissector.deserializers.update-fail-malformed-htlc"] = "src/deserializers/update-fail-malformed-htlc.lua",
    ["lightning-dissector.deserializers.commitment-signed"] = "src/deserializers/commitment-signed.lua",
    ["lightning-dissector.deserializers.revoke-and-ack"] = "src/deserializers/revoke-and-ack.lua",
    ["lightning-dissector.deserializers.update-fee"] = "src/deserializers/update-fee.lua",
    ["lightning-dissector.deserializers.announcement-signatures"] = "src/deserializers/announcement-signatures.lua",
    ["lightning-dissector.deserializers.query-short-channel-ids"] = "src/deserializers/query-short-channel-ids.lua",
    ["lightning-dissector.deserializers.reply-short-channel-ids-end"] = "src/deserializers/reply-short-channel-ids-end.lua",
    ["lightning-dissector.deserializers.query-channel-range"] = "src/deserializers/query-channel-range.lua",
    ["lightning-dissector.deserializers.reply-channel-range"] = "src/deserializers/reply-channel-range.lua",
    ["lightning-dissector.deserializers.gossip-timestamp-filter"] = "src/deserializers/gossip-timestamp-filter.lua",
    ["lightning-dissector.utils"] = "src/utils.lua",
    ["plc52.bin"] = "plc/plc/bin.lua",
    ["plc52.chacha20"] = "plc/plc/chacha20.lua"
  }
}
