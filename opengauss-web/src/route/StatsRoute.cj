package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerStatsRoutes(server: Server, svc: StatsService) {
    server.distributor.register("/api/stats/departments", {
        ctx => jsonResponse(ctx, svc.deptStats())
    })
    server.distributor.register("/api/stats/projects", {
        ctx => jsonResponse(ctx, svc.projectStats())
    })
    server.distributor.register("/api/stats/salary-ranking", {
        ctx => jsonResponse(ctx, svc.salaryRanking())
    })
}
