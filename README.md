# lightning-dissector
A wireshark plugin to analyze communication between Lightning Network nodes

![](https://user-images.githubusercontent.com/12756700/45472759-1b79fe00-b770-11e8-812b-f73e8cd18ab6.png)

## Install
```
luarocks install --local https://raw.githubusercontent.com/nayutaco/poly1305.lua/master/poly1305-scm-1.rockspec
luarocks install --local https://raw.githubusercontent.com/nayutaco/plc/lua5.2/rockspec/plc-0.5-2.rockspec
luarocks install --local https://raw.githubusercontent.com/nayutaco/lightning-dissector/master/lightning-dissector-scm-1.rockspec
mkdir -p ~/.config/wireshark/plugins
ln -s ~/.luarocks/share/lua/5.2/lightning-dissector/wireshark-plugin.lua ~/.config/wireshark/plugins/lightning-dissector.lua
```

## Setup
### Eclair
Set loglevel to DEBUG.  
lightning-dissector searches debug log for decryption key.

```bash
sed -i 's/<root level="INFO">/<root level="DEBUG">/' eclair-node/src/main/resources/logback.xml
```

### Ptarmigan
Set `$LIGHTNINGKEYLOGFILE` before starting ptarmigan.  
lightning-dissector searches that file for decryption key.

```bash
mkdir ~/.cache/lightning-dissector
export LIGHTNINGKEYLOGFILE=~/.cache/lightning-dissector/keys.log 
```

## Status
### Limitation
Currently, lightning-dissector needs Wireshark already started at the time lightning nodes start handshaking.    
If not, all decryptions will fail.

### Supported implementations
Currently, lightning-dissector can decrypt messages sent from / received by
- eclair
- ptarmigan

Also [you can analyze messages of unsupported implementations by specifying decryption keys manually.](https://github.com/nayutaco/lightning-dissector/blob/master/CONTRIBUTING.md#by-using-key-dump-file)

If you are developer of some BOLT implementation, I need your help!  
[You can make lightning-dissector support your implementation by writing a SecretManager.](https://github.com/nayutaco/lightning-dissector/blob/master/CONTRIBUTING.md#by-writing-a-new-secretmanager)

### Supported BOLT messages
Currently, lightning-dissector can deserialize
- init
- ping
- pong
- error
- channel_announcement
- node_announcement
- channel_update

I'm working on another messages.  
And [you can write deserializers for another messages easily.](https://github.com/nayutaco/lightning-dissector/blob/master/CONTRIBUTING.md)
