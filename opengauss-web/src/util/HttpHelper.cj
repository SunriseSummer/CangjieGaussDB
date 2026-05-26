package opengauss_web.util

import stdx.net.http.*
import stdx.encoding.url.*
import std.io.*
import std.convert.*
import std.env.*

public func readBody(ctx: HttpContext): String {
    let buf = ByteBuffer()
    let tmp = Array<Byte>(4096, repeat: 0)
    while (true) {
        let n = ctx.request.body.read(tmp)
        if (n <= 0) { break }
        buf.write(tmp[0..n])
    }
    buf.seek(Begin(0))
    return StringReader(buf).readToEnd()
}

public func parseForm(body: String): Form {
    return URL.parse("http://x/?${body}").queryForm
}

public func jsonResponse(ctx: HttpContext, body: String) {
    ctx.responseBuilder
        .status(200)
        .header("content-type", "application/json; charset=utf-8")
        .body(body)
}

public func notAllowed(ctx: HttpContext) {
    ctx.responseBuilder
        .status(405)
        .header("content-type", "application/json; charset=utf-8")
        .body("{\"error\":\"Method not allowed\"}")
}

public func parseInt64Or(input: String, fallback: Int64): Int64 {
    try {
        return Int64.parse(input)
    } catch (_: Exception) {
        return fallback
    }
}

public func envOr(key: String, fallback: String): String {
    return getVariable(key) ?? fallback
}
