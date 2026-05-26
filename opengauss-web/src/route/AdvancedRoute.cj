package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerAdvancedRoutes(server: Server, svc: AdvancedService) {
    server.distributor.register("/api/advanced/views", {
        ctx =>
            if (ctx.request.method == "GET") {
                jsonResponse(ctx, svc.listViews())
            } else if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.createView(
                    f.get("name") ?? "", f.get("query") ?? ""
                ))
            } else {
                notAllowed(ctx)
            }
    })

    server.distributor.register("/api/advanced/indexes", {
        ctx =>
            if (ctx.request.method == "GET") {
                jsonResponse(ctx, svc.listIndexes())
            } else if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.createIndex(
                    f.get("table") ?? "", f.get("column") ?? ""
                ))
            } else {
                notAllowed(ctx)
            }
    })

    server.distributor.register("/api/advanced/batch-insert", {
        ctx =>
            if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                let count = parseInt64Or(f.get("count") ?? "0", 0)
                let prefix = f.get("prefix") ?? "User"
                let deptId = parseInt64Or(f.get("department_id") ?? "1", 1)
                let data = Array<(String, String, Int64)>(count) {
                    i => ("${prefix}_${i+1}",
                          "${prefix.toArray()[0]}${i+1}@example.com",
                          deptId)
                }
                jsonResponse(ctx, svc.batchInsert(data))
            } else {
                notAllowed(ctx)
            }
    })

    server.distributor.register("/api/advanced/transfer", {
        ctx =>
            if (ctx.request.method == "POST") {
                let f = parseForm(readBody(ctx))
                jsonResponse(ctx, svc.transfer(
                    parseInt64Or(f.get("from_id") ?? "0", 0),
                    parseInt64Or(f.get("to_id") ?? "0", 0),
                    f.get("amount") ?? "0"
                ))
            } else {
                notAllowed(ctx)
            }
    })

    server.distributor.register("/api/advanced/aggregates", {
        ctx => jsonResponse(ctx, svc.aggregates())
    })

    server.distributor.register("/api/advanced/subquery", {
        ctx => jsonResponse(ctx, svc.subquery())
    })
}
