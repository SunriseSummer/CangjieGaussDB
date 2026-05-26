package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerEmpRoutes(server: Server, svc: EmpService) {
    server.distributor.register("/api/employees", {
        ctx =>
            if (ctx.request.method == "GET") {
                let q = ctx.request.url.queryForm.get("search") ?? ""
                if (q.size > 0) {
                    jsonResponse(ctx, svc.search(q))
                } else {
                    jsonResponse(ctx, svc.list())
                }
            } else if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.add(
                    f.get("name") ?? "", f.get("email") ?? "",
                    f.get("phone") ?? "",
                    parseInt64Or(f.get("department_id") ?? "0", 0),
                    f.get("position") ?? "", f.get("salary") ?? "0"
                ))
            } else if (ctx.request.method == "PUT") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.update(
                    parseInt64Or(f.get("id") ?? "0", 0),
                    f.get("name") ?? "", f.get("email") ?? "",
                    f.get("phone") ?? "",
                    parseInt64Or(f.get("department_id") ?? "0", 0),
                    f.get("position") ?? "", f.get("salary") ?? "0"
                ))
            } else if (ctx.request.method == "DELETE") {
                let id = parseInt64Or(ctx.request.url.queryForm.get("id") ?? "0", 0)
                jsonResponse(ctx, svc.delete(id))
            } else {
                notAllowed(ctx)
            }
    })
}
