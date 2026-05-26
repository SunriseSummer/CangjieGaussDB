package opengauss_web.util

public func isSelectQuery(sqlStr: String): Bool {
    let bytes = sqlStr.toArray()
    let start = skipNoise(bytes)
    let tail = bytes[start..bytes.size]
    if (tail.size < 6 || hasMultiStmt(tail)) {
        return false
    }
    return upper(tail[0]) == 83 &&   // S
        upper(tail[1]) == 69 &&      // E
        upper(tail[2]) == 76 &&      // L
        upper(tail[3]) == 69 &&      // E
        upper(tail[4]) == 67 &&      // C
        upper(tail[5]) == 84         // T
}

func upper(b: UInt8): UInt8 {
    if (b >= 97 && b <= 122) { return b - 32 }
    return b
}

func isSpace(b: UInt8): Bool {
    return b == 32 || b == 9 || b == 10 || b == 13
}

func skipNoise(bytes: Array<UInt8>): Int64 {
    var i: Int64 = 0
    while (i < bytes.size) {
        while (i < bytes.size && isSpace(bytes[i])) { i += 1 }
        if (i + 1 < bytes.size && bytes[i] == 47 && bytes[i + 1] == 42) {
            i += 2
            while (i + 1 < bytes.size && !(bytes[i] == 42 && bytes[i + 1] == 47)) {
                i += 1
            }
            if (i + 1 < bytes.size) { i += 2 }
            continue
        }
        if (i + 1 < bytes.size && bytes[i] == 45 && bytes[i + 1] == 45) {
            i += 2
            while (i < bytes.size && bytes[i] != 10) { i += 1 }
            continue
        }
        break
    }
    return i
}

func hasMultiStmt(bytes: Array<UInt8>): Bool {
    var seen = false
    for (k in 0..bytes.size) {
        if (bytes[k] == 59) {
            seen = true
        } else if (seen && !isSpace(bytes[k])) {
            return true
        }
    }
    return false
}
