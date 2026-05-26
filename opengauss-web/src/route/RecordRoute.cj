package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerRecordRoutes(server: Server, svc: RecordService) {
    server.distributor.register("/api/attendance", {
        ctx => jsonResponse(ctx, svc.attendance())
    })
    server.distributor.register("/api/reviews", {
        ctx => jsonResponse(ctx, svc.reviews())
    })
    server.distributor.register("/api/salary-history", {
        ctx => jsonResponse(ctx, svc.salaryHistory())
    })
    server.distributor.register("/api/logs", {
        ctx => jsonResponse(ctx, svc.logs())
    })
}
