# Add support for another implementation
## By dumping key log file
You can make your BOLT implementation support lightning-dissector by dumping a file called key log file.  
Every line of the key log file consists of:  
```
<16-byte MAC of the encrypted message length> <rk or sk to decrypt that message>
```
[BOLT #8](https://github.com/lightningnetwork/lightning-rfc/blob/master/08-transport.md#lightning-message-specification) describes those meaning.  
Both must be encoded as hex string like:  
```
f5c824813efadaa8cb34b52fca45d8e6 9971413e29a98f2f173d19f405561c6ccebec1a88d358fab59ff32fb33cbe008
```
Implementations must insert a new line to the key log file when key rotation happens.  
lightning-dissector reads key log files set in Wireshark preference `Protocols -> LIGHTNING -> Key log file`.

## By writing a new SecretFactory
You can add support for another implementation by writing a new [SecretFactory](https://github.com/nayutaco/lightning-dissector/blob/master/src/secret-factory.lua).  
and put its instance to [here](https://github.com/nayutaco/lightning-dissector/blob/f0a8a38eee84a4cabee2372d80433b5fa33da43c/src/wireshark-plugin.lua#L35).

# Add support for another message
You can add support for another message by writing a new [deserializer like this](https://github.com/nayutaco/lightning-dissector/blob/master/src/deserializers/ping.lua).  
and put it [here](https://github.com/nayutaco/lightning-dissector/blob/f0a8a38eee84a4cabee2372d80433b5fa33da43c/src/pdu-analyzer.lua#L5).
