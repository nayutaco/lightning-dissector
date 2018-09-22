package = "lightning-dissector"
version = "0.1-1"

source = {
  url = "https://media.githubusercontent.com/media/nayutaco/lightning-dissector/4cd403abe65ce9f50217a3a8d96077f21197fee2/releases/lightning-dissector-0.1.tar.gz"
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
  "poly1305 == 1.0"
}

build = {
  type = "builtin",
  modules = {
    ["lightning-dissector.wireshark-plugin"] = "src/wireshark-plugin.lua",
    ["lightning-dissector.pdu-analyzer"] = "src/pdu-analyzer.lua",
    ["lightning-dissector.secret"] = "src/secret.lua",
    ["lightning-dissector.secret-manager"] = "src/secret-manager.lua",
    ["lightning-dissector.secret-cache"] = "src/secret-cache.lua",
    ["lightning-dissector.deserializers.init"] = "src/deserializers/init.lua",
    ["lightning-dissector.deserializers.ping"] = "src/deserializers/ping.lua",
    ["lightning-dissector.deserializers.pong"] = "src/deserializers/pong.lua",
    ["lightning-dissector.deserializers.error"] = "src/deserializers/error.lua",
    ["lightning-dissector.deserializers.channel-announcement"] = "src/deserializers/channel-announcement.lua",
    ["lightning-dissector.deserializers.channel-update"] = "src/deserializers/channel-update.lua",
    ["lightning-dissector.deserializers.node-announcement"] = "src/deserializers/node-announcement.lua",
    ["lightning-dissector.utils.reader"] = "src/utils/reader.lua",
    ["plc52.bin"] = "plc/plc/bin.lua",
    ["plc52.chacha20"] = "plc/plc/chacha20.lua"
  }
}
