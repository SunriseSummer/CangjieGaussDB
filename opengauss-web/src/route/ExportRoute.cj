package opengauss_web.route

import opengauss_web.service.*
import opengauss_web.util.*
import stdx.net.http.*

public func registerExportRoutes(server: Server, svc: ExportService) {
    server.distributor.register("/api/export/employees", {
        ctx =>
            ctx.responseBuilder
                .status(200)
                .header("content-type", "text/csv; charset=utf-8")
                .header("content-disposition", "attachment; filename=employees.csv")
                .body(svc.employeesCsv())
    })

    server.distributor.register("/api/export/dept-stats", {
        ctx =>
            ctx.responseBuilder
                .status(200)
                .header("content-type", "text/csv; charset=utf-8")
                .header("content-disposition", "attachment; filename=dept_stats.csv")
                .body(svc.deptStatsCsv())
    })
}
