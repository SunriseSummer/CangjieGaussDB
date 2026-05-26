package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerDeptRoutes(server: Server, svc: DeptService) {
    server.distributor.register("/api/departments", {
        ctx =>
            if (ctx.request.method == "GET") {
                jsonResponse(ctx, svc.list())
            } else if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.add(f.get("name") ?? "", f.get("description") ?? ""))
            } else if (ctx.request.method == "DELETE") {
                let id = parseInt64Or(ctx.request.url.queryForm.get("id") ?? "0", 0)
                jsonResponse(ctx, svc.delete(id))
            } else {
                notAllowed(ctx)
            }
    })
}
