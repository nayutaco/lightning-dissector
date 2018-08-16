# lightning-dissector
A wireshark plugin to analyze communication between Lightning Network nodes

## Installation
```
sudo luarocks install lrexlib-pcre
sudo luarocks install https://raw.githubusercontent.com/tock203/plc/lua5.2/rockspec/plc-0.5-2.rockspec

mkdir -p ~/.config/wireshark/plugins
cd ~/.config/wireshark/plugins
wget https://raw.githubusercontent.com/tock203/lightning-dissector/master/lightning-dissector.lua
```
