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

      }
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
