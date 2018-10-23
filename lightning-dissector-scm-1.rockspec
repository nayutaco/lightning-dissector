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
  "middleclass == 4.1.1"
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
    ["lightning-dissector.utils"] = "src/utils.lua",
    ["plc52.bin"] = "plc/plc/bin.lua",
    ["plc52.chacha20"] = "plc/plc/chacha20.lua"
  }
}
