package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerSqlRoute(server: Server, svc: SqlService) {
    server.distributor.register("/api/sql", {
        ctx =>
            if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.execute(f.get("sql") ?? ""))
            } else {
                notAllowed(ctx)
            }
    })
}
