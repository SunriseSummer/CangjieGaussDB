package opengauss_web.dao

import std.collection.*

public func escapeJson(s: String): String {
    let bytes = s.toArray()
    let result = ArrayList<UInt8>()
    for (b in bytes) {
        if (b == 34) {         // "
            result.add(92)
            result.add(34)
        } else if (b == 92) {  // \
            result.add(92)
            result.add(92)
        } else if (b == 10) {  // \n
            result.add(92)
            result.add(110)
        } else if (b == 13) {  // \r
            result.add(92)
            result.add(114)
        } else if (b == 9) {   // \t
            result.add(92)
            result.add(116)
        } else {
            result.add(b)
        }
    }
    return String.fromUtf8(result.toArray())
}

public func jsonOk(message: String): String {
    return "{\"success\":true,\"message\":\"${escapeJson(message)}\"}"
}

public func jsonFail(message: String): String {
    return "{\"success\":false,\"message\":\"${escapeJson(message)}\"}"
}
