# Add support for another implementation
## By using key dump file
lightning-dissector watches $LIGHTNINGKEYLOGFILE (by default ~/.cache/lightning-dissector/keys.log) to find the keys to decrypt messages.  
Every line of $LIGHTNINGKEYLOGFILE consists of:  
```
<16-byte MAC of the encrypted message length> <rk or sk to decrypt that message>
```
What those mean is described in [BOLT #8](https://github.com/lightningnetwork/lightning-rfc/blob/master/08-transport.md#lightning-message-specification).  
When key rotation happens, a new line must be inserted in $LIGHTNINGKEYLOGFILE.

So you can analyze lightning messages between unsupported implementations by doing above.

## By writing a new SecretManager
TODO
