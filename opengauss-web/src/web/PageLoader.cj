package opengauss_web.web

import std.fs.*
import std.io.*

public func loadHtmlPage(): String {
    let path = Path("static/index.html")
    let file = File(path, Read)
    try {
        let bytes = readToEnd(file)
        return String.fromUtf8(bytes)
    } finally {
        file.close()
    }
}
