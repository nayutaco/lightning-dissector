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
    "compat53 == 0.7"
}

build = {
    type = "builtin",
    modules = {
        ["lightning-dissector.wireshark-plugin"] = "wireshark-plugin.lua",
        ["lightning-dissector.decryptor"] = "decryptor.lua"
    }
}
