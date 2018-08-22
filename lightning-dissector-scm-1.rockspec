package = "lightning-dissector"
version = "scm-1"

source = {
    url = "git://github.com/tock203/lightning-dissector.git",
}

description = {
    summary = "Lightning Dissector",
    detailed = [[
        A wireshark plugin to analyze communication between lightning network nodes.
    ]],
    homepage = "https://github.com/tock203/lightning-dissector",
    license = "MIT",
}

dependencies = { 
    "lua == 5.2",
    "lrexlib-pcre == 2.9.0",
    "compat53 == 0.7",
    "inspect == 3.1.1"
}

build = {
    type = "builtin",
    modules = {
        ["lightning-dissector.wireshark-plugin"] = "wireshark-plugin.lua",
        ["lightning-dissector.decryptor"] = "decryptor.lua",
        ["lightning-dissector.key"] = "key.lua",
        ["lightning-dissector.frame-analyzer"] = "frame-analyzer.lua",
        ["lightning-dissector.deserializers.init"] = "deserializers/init.lua",
        ["lightning-dissector.deserializers.ping"] = "deserializers/ping.lua",
        ["lightning-dissector.deserializers.pong"] = "deserializers/pong.lua",
        ["lightning-dissector.utils.reader"] = "utils/reader.lua"
    }
}
