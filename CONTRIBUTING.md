# Support for your own BOLT implementation
## By dumping key log file
Your own BOLT implementation can use lightning-dissector by dumping key log file.  
Whenever key lotation happens, BOLT implementation write out <16byte MAC & key> of "first BOLT packet" to key log file.   
Every line of the key log file consists of:  
```
<16-byte MAC of the encrypted message length> <rk or sk to decrypt that message>
```
[BOLT #8](https://github.com/lightningnetwork/lightning-rfc/blob/master/08-transport.md#lightning-message-specification) describes each item in detail.  
Both items must be encoded as hex string like:  
```
f5c824813efadaa8cb34b52fca45d8e6 9971413e29a98f2f173d19f405561c6ccebec1a88d358fab59ff32fb33cbe008
```
Implementations must insert a new line to the key log file when key rotation happens.  
When you use Wireshark, you can specify key log file by Wireshark preference `Protocols -> LIGHTNING -> Key log file`.

## By writing a new SecretFactory
Your own BOLT implementation can use lightning-dissector by writing a new [SecretFactory](https://github.com/nayutaco/lightning-dissector/blob/master/src/secret-factory.lua).  
and put its instance to [here](https://github.com/nayutaco/lightning-dissector/blob/f0a8a38eee84a4cabee2372d80433b5fa33da43c/src/wireshark-plugin.lua#L35).

# Add support for another message
You can add support for another message by writing a new [deserializer like this](https://github.com/nayutaco/lightning-dissector/blob/master/src/deserializers/ping.lua).  
and put it [here](https://github.com/nayutaco/lightning-dissector/blob/f0a8a38eee84a4cabee2372d80433b5fa33da43c/src/pdu-analyzer.lua#L5).
