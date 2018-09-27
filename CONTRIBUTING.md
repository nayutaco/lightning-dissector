# Add support for another implementation
You can add support for another implementation by writing a new [SecretFactory](https://github.com/nayutaco/lightning-dissector/blob/7bd56fcfaa8b5326f7c8cf0418a0a149c26bcfdf/src/secret-factory.lua#L7).  
and put its instance to [here](https://github.com/nayutaco/lightning-dissector/blob/7bd56fcfaa8b5326f7c8cf0418a0a149c26bcfdf/src/wireshark-plugin.lua#L35).

# Add support for another message
You can add support for another message by writing a new [deserializer like this](https://github.com/nayutaco/lightning-dissector/blob/master/src/deserializers/ping.lua).  
and put its instance to [here](https://github.com/nayutaco/lightning-dissector/blob/7bd56fcfaa8b5326f7c8cf0418a0a149c26bcfdf/src/pdu-analyzer.lua#L5).
