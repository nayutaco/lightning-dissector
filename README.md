# lightning-dissector
A wireshark plugin to analyze communication between Lightning Network nodes

## Installation
```
sudo luarocks install https://raw.githubusercontent.com/tock203/plc/lua5.2/rockspec/plc-0.5-2.rockspec
sudo luarocks install https://raw.githubusercontent.com/tock203/lightning-dissector/master/lightning-dissector-scm-1.rockspec
mkdir -p ~/.config/wireshark/plugins
ln -s /usr/local/share/lua/5.2/lightning-dissector/wireshark-plugin.lua ~/.config/wireshark/plugins/lightning-dissector.lua
```
