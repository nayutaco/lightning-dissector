local fields = {
  secret = {
    key = ProtoField.new("Key", "lightning.secret.key", ftypes.STRING),
    nonce = {
      raw = ProtoField.new("Raw", "lightning.secret.nonce.raw", ftypes.STRING),
      deserialized = ProtoField.new("Deserialized", "lightning.secret.nonce.deserialized", ftypes.UINT16)
    }
  },
  length = {
    encrypted = ProtoField.new("Encrypted", "lightning.length.encrypted", ftypes.STRING),
    decrypted = ProtoField.new("Decrypted", "lightning.length.decrypted", ftypes.STRING),
    deserialized = ProtoField.new("Deserialized", "lightning.length.deserialized", ftypes.UINT16),
    mac = ProtoField.new("MAC", "lightning.length.mac", ftypes.STRING)
  },
  payload = {
    encrypted = ProtoField.new("Encrypted", "lightning.payload.encrypted", ftypes.STRING),
    decrypted = ProtoField.new("Decrypted", "lightning.payload.decrypted", ftypes.STRING),
    mac = ProtoField.new("MAC", "lightning.payload.mac", ftypes.STRING),
    deserialized = {
      type = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.type.raw", ftypes.STRING),
        name = ProtoField.new("Name", "lightning.payload.deserialized.type.name", ftypes.STRING),
        number = ProtoField.new("Number", "lightning.payload.deserialized.type.number", ftypes.UINT16)
      },
      gflen = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.gflen.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.gflen.deserialized", ftypes.UINT16)
      },
      global_features = ProtoField.new("global_features", "lightning.payload.deserialized.global_features", ftypes.STRING),
      lflen = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.lflen.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.lflen.deserialized", ftypes.UINT16)
      },
      local_features = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.local_features.raw", ftypes.STRING),
        deserialized = {
          optional = ProtoField.new("Optional", "lightning.payload.deserialized.local_features.deserialized.optional", ftypes.STRING),
          required = ProtoField.new("Required", "lightning.payload.deserialized.local_features.deserialized.required", ftypes.STRING)
        }
      },
      signature = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.signature.raw", ftypes.STRING),
        der = ProtoField.new("DER", "lightning.payload.deserialized.signature.der", ftypes.STRING)
      },
      chain_hash = ProtoField.new("chain_hash", "lightning.payload.deserialized.chain_hash", ftypes.STRING),
      short_channel_id = ProtoField.new("short_channel_id", "lightning.payload.deserialized.short_channel_id", ftypes.STRING),
      timestamp = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.timestamp.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.timestamp.deserialized", ftypes.UINT32)
      },
      message_flags = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.message_flags.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.message_flags.deserialized", ftypes.STRING)
      },
      channel_flags = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.channel_flags.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.channel_flags.deserialized", ftypes.STRING)
      },
      cltv_expiry_delta = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.cltv_expiry_delta.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.cltv_expiry_delta", ftypes.UINT16)
      },
      htlc_minimum_msat = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.htlc_minimum_msat.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.htlc_minimum_msat.deserialized", ftypes.UINT64)
      },
      fee_base_msat = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.fee_base_msat.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.fee_base_msat.deserialized", ftypes.UINT32)
      },
      fee_proportional_millionths = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.fee_proportional_millionths.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.fee_proportional_millionths.deserialized", ftypes.UINT32)
      },
      htlc_maximum_msat = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.htlc_maximum_msat.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.htlc_maximum_msat.deserialized", ftypes.UINT64)
      },
      flen = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.flen.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.flen.deserialized", ftypes.UINT16)
      },
      features = ProtoField.new("features", "lightning.payload.deserialized.features", ftypes.STRING),
      node_id = ProtoField.new("node_id", "lightning.payload.deserialized.node_id", ftypes.STRING),
      rgb_color = ProtoField.new("rgb_color", "lightning.payload.deserialized.rgb_color", ftypes.STRING),
      alias = ProtoField.new("alias", "lightning.payload.deserialized.alias", ftypes.STRING),
      addrlen = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.addrlen.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.addrlen.deserialized", ftypes.UINT16)
      },
      addresses = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.addresses.raw", ftypes.STRING),
        deserialized = {
          type = ProtoField.new("type", "lightning.payload.deserialized.addresses.deserialized.type", ftypes.STRING),
          addr = ProtoField.new("addr", "lightning.payload.deserialized.addresses.deserialized.addr", ftypes.STRING),
          port = ProtoField.new("port", "lightning.payload.deserialized.addresses.deserialized.port", ftypes.UINT16)
        }
      },
      num_pong_bytes = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.num_pong_bytes.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.num_pong_bytes.deserialized", ftypes.UINT16)
      },
      byteslen = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.byteslen.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.byteslen.deserialized", ftypes.UINT16)
      },
      ignored = ProtoField.new("ignored", "lightning.payload.deserialized.ignored", ftypes.STRING),
      channel_id = ProtoField.new("channel_id", "lightning.payload.deserialized.channel_id", ftypes.STRING),
      len = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.len.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.len.deserialized", ftypes.UINT16)
      },
      data = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.data.raw", ftypes.STRING),
        deserialized = ProtoField.new("Deserialized", "lightning.payload.deserialized.data.deserialized", ftypes.STRING)
      },
      node_signature_1 = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.node_signature_1.raw", ftypes.STRING),
        der = ProtoField.new("DER", "lightning.payload.deserialized.node_signature_1.der", ftypes.STRING)
      },
      node_signature_2 = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.node_signature_2.raw", ftypes.STRING),
        der = ProtoField.new("DER", "lightning.payload.deserialized.node_signature_2.der", ftypes.STRING)
      },
      bitcoin_signature_1 = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.bitcoin_signature_1.raw", ftypes.STRING),
        der = ProtoField.new("DER", "lightning.payload.deserialized.bitcoin_signature_1.der", ftypes.STRING)
      },
      bitcoin_signature_2 = {
        raw = ProtoField.new("Raw", "lightning.payload.deserialized.bitcoin_signature_2.raw", ftypes.STRING),
        der = ProtoField.new("DER", "lightning.payload.deserialized.bitcoin_signature_2.der", ftypes.STRING)
      },
      node_id_1 = ProtoField.new("node_id_1", "lightning.payload.deserialized.node_id_1", ftypes.STRING),
      node_id_2 = ProtoField.new("node_id_2", "lightning.payload.deserialized.node_id_2", ftypes.STRING),
      bitcoin_key_1 = ProtoField.new("bitcoin_key_1", "lightning.payload.deserialized.bitcoin_key_1", ftypes.STRING),
      bitcoin_key_2 = ProtoField.new("bitcoin_key_2", "lightning.payload.deserialized.bitcoin_key_2", ftypes.STRING)
    }
  }
}

local fields_array = {}
function flatten(fields)
  for _, value in pairs(fields) do
    local proto_field_type = "userdata"
    if type(value) == proto_field_type then
      table.insert(fields_array, value)
    else
      flatten(value)
    end
  end
end
flatten(fields)

return {
  lengths = {
    length = 2,
    length_mac = 16,
    payload_mac = 16,
    header = 18,
    footer = 16
  },
  fields_array = fields_array,
  fields = fields
}
