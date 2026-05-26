package opengauss_web

import opengauss_web.dao.*
import opengauss_web.service.*
import opengauss_web.route.*
import opengauss_web.web.*
import opengauss_web.util.*
import stdx.net.http.*
import std.convert.*

main(): Unit {
    let dbUrl = envOr("OPENGAUSS_WEB_DB_URL",
        "opengauss://gaussdb:Root%40123456@127.0.0.1:15432/omm?sslmode=disable")
    let host = envOr("OPENGAUSS_WEB_HOST", "127.0.0.1")
    let port = UInt16(parseInt64Or(envOr("OPENGAUSS_WEB_PORT", "8080"), 8080))

    let db = DbConnector(dbUrl)
    let htmlPage = loadHtmlPage()

    println("OpenGauss Web Console")
    println("  DB : ${dbUrl}")
    println("  URL: http://${host}:${port}")

    let server = ServerBuilder().addr(host).port(port).build()

    server.distributor.register("/", {
        ctx => ctx.responseBuilder.status(200)
            .header("content-type", "text/html; charset=utf-8")
            .body(htmlPage)
    })

    registerDeptRoutes(server, DeptService(db))
    registerEmpRoutes(server, EmpService(db))
    registerProjectRoutes(server, ProjectService(db))
    registerStatsRoutes(server, StatsService(db))
    registerRecordRoutes(server, RecordService(db))
    registerAdvancedRoutes(server, AdvancedService(db))
    registerSqlRoute(server, SqlService(db))
    registerExportRoutes(server, ExportService(db))

    server.serve()
}
