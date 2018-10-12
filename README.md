# lightning-dissector
A wireshark plugin to analyze communication between Lightning Network nodes

![](https://user-images.githubusercontent.com/12756700/45472759-1b79fe00-b770-11e8-812b-f73e8cd18ab6.png)

## Installation
```bash
git clone https://github.com/nayutaco/lightning-dissector.git --recursive
cd lightning-dissector
luarocks --local make
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

You can set location for the debug log by `Edit Menu -> Preferences -> Protocols -> LIGHTNING`. (~/.eclair/eclair.log by default)

### Ptarmigan
You need to build ptarmigan with developer mode enabled.
```bash
sed -i 's/ENABLE_DEVELOPER_MODE=0/ENABLE_DEVELOPER_MODE=1/g' options.mak
make full
```

Set `$LIGHTNINGKEYLOGFILE` before starting ptarmigan.  
ptarmigan dumps decryption keys to there.

```bash
mkdir ~/.cache/ptarmigan
export LIGHTNINGKEYLOGFILE=~/.cache/ptarmigan/keys.log 
```

You should set `$LIGHTNINGKEYLOGFILE` value and `Protocols -> LIGHTNING -> Key log file` preference same. (~/.cache/ptarmigan/keys.log by default)

## Status
### Supported implementations
Currently, lightning-dissector can decrypt messages sent from / received by
- eclair
- ptarmigan

If you are developer of some BOLT implementation, I need your help!  
[You can make your BOLT implementation support lightning-dissector by dumping key log file, or writing a new SecretManager](https://github.com/nayutaco/lightning-dissector/blob/master/CONTRIBUTING.md).

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
Contributions by [writing deserializers for another messages](https://github.com/nayutaco/lightning-dissector/blob/master/CONTRIBUTING.md#add-support-for-another-message) are welcome.
