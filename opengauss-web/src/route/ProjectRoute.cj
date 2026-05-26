package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerProjectRoutes(server: Server, svc: ProjectService) {
    server.distributor.register("/api/projects", {
        ctx =>
            if (ctx.request.method == "GET") {
                jsonResponse(ctx, svc.list())
            } else if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.add(
                    f.get("name") ?? "", f.get("description") ?? "",
                    parseInt64Or(f.get("department_id") ?? "0", 0),
                    f.get("budget") ?? "0"
                ))
            } else if (ctx.request.method == "PUT") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.updateStatus(
                    parseInt64Or(f.get("id") ?? "0", 0),
                    f.get("status") ?? ""
                ))
            } else if (ctx.request.method == "DELETE") {
                let id = parseInt64Or(ctx.request.url.queryForm.get("id") ?? "0", 0)
                jsonResponse(ctx, svc.delete(id))
            } else {
                notAllowed(ctx)
            }
    })
}
