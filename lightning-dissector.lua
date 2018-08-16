re = require "rex_pcre"
inspect = require "inspect"
bin = require "plc.bin"
chacha = require "plc.chacha20"

lightning_proto = Proto("lightning", "Lightning Network")
analyzed_frames = {}
sk_hex = nil
sn = 0

function hexNonce(nonce)
    return "\x00\x00\x00\x00" .. string.pack("I8", nonce)
end

function decrypt(ciphertext)
    local decrypted = chacha.decrypt(sk_hex, 1, hexNonce(sn), ciphertext)
    sn = sn + 1
    return decrypted
end

function prepareKey()
    if sk_hex == nil then
        local f = io.open("/home/tock/GitHub/nayutaco/ptarmigan/install/logs/plog.log")
        local log = f:read("*all")
        f:close()

        local sk = re.match(log, "sk: (.+)")
        if sk ~= nil then
            sk_hex = bin.hextos(sk)
        end
    end
end

function analyze(pinfo, buffer)
    prepareKey()

    local encrypted_len = buffer():raw(0, 2)
    local decrypted_len = decrypt(encrypted_len)
    local encrypted_msg = buffer():raw(18)
    local decrypted_msg = decrypt(encrypted_msg)

    local type = string.unpack(">I2", decrypted_msg:sub(1,2))
    local INIT = 16
    if sn == 2 and type ~= INIT then
        -- sn is 0 until init message comes, which means handshake finished
        sn = 0
        return nil
    end

    local result = {
        sk = sk_hex,
        sn = hexNonce(sn),
        encrypted_len = encrypted_len,
        decrypted_len = decrypted_len,
        encrypted_msg = encrypted_msg,
        decrypted_msg = decrypted_msg
    }
    info(inspect(result))

    return result
end

function display(analyzed_frame, buffer, tree)
    local subtree = tree:add(lightning_proto, buffer(), "Lightning Network")
    subtree:add(buffer(0, 0), "sk: " .. bin.stohex(analyzed_frame.sk))
    subtree:add(buffer(0, 0), "sn: " .. bin.stohex(analyzed_frame.sn))
    subtree:add(buffer(0, 0), "encrypted_len: " .. bin.stohex(analyzed_frame.encrypted_len))
    subtree:add(buffer(0, 0), "decrypted_len: " .. bin.stohex(analyzed_frame.decrypted_len))
    subtree:add(buffer(0, 0), "encrypted_msg: " .. bin.stohex(analyzed_frame.encrypted_msg))
    subtree:add(buffer(0, 0), "decrypted_msg: " .. bin.stohex(analyzed_frame.decrypted_msg))
end

function lightning_proto.dissector(buffer, pinfo, tree)
    if pinfo.dst_port ~= 9000 then
        return
    end

    pinfo.cols.protocol = "Lightning Network"
--
    local analyzed_frame = analyzed_frames[pinfo.number]
    if analyzed_frame == nil then
        analyzed_frames[pinfo.number] = analyze(pinfo, buffer)
    else
        display(analyzed_frame, buffer, tree)
    end
end

DissectorTable.get("tcp.port"):add(9000, lightning_proto)
