package opengauss_web

import opengauss_web.dao.*
import opengauss_web.service.*
import opengauss_web.web.*
import stdx.net.http.*
import stdx.encoding.url.*
import std.io.*
import std.convert.*
import std.env.*

func parseBodyForm(body: String): Form {
    let url = URL.parse("http://localhost/?" + body)
    return url.queryForm
}

func parseInt64OrDefault(input: String, defaultValue: Int64): Int64 {
    try {
        return Int64.parse(input)
    } catch (_: Exception) {
        return defaultValue
    }
}

func getEnvOrDefault(key: String, defaultValue: String): String {
    return getVariable(key) ?? defaultValue
}

func readBody(ctx: HttpContext): String {
    let collector = ByteBuffer()
    let buffer = Array<Byte>(4096, repeat: 0)
    while (true) {
        let n = ctx.request.body.read(buffer)
        if (n <= 0) {
            break
        }
        collector.write(buffer[0..n])
    }
    collector.seek(Begin(0))
    return StringReader(collector).readToEnd()
}

func jsonResponse(ctx: HttpContext, body: String) {
    ctx.responseBuilder.status(200).header("content-type", "application/json; charset=utf-8").body(body)
}

func notAllowed(ctx: HttpContext) {
    ctx.responseBuilder.status(405).header("content-type", "application/json; charset=utf-8").body("{\"error\":\"Method not allowed\"}")
}

main(): Unit {
    let dbUrl = getEnvOrDefault("OPENGAUSS_WEB_DB_URL", "opengauss://gaussdb:Root%40123456@127.0.0.1:15432/omm?sslmode=disable")
    let bindAddr = getEnvOrDefault("OPENGAUSS_WEB_HOST", "127.0.0.1")
    let serverPort = UInt16(parseInt64OrDefault(getEnvOrDefault("OPENGAUSS_WEB_PORT", "8080"), 8080))
    let db = DbConnector(dbUrl)
    let service = DataService(db)

    println("Starting OpenGauss Web Console...")
    println("Database URL: ${dbUrl}")
    println("Bind Address: ${bindAddr}:${serverPort}")

    let server = ServerBuilder().addr(bindAddr).port(serverPort).build()

    server.distributor.register("/", {
        ctx => ctx.responseBuilder.status(200).header("content-type", "text/html; charset=utf-8").body(HTML_PAGE)
    })

    server.distributor.register("/api/departments", {
        ctx =>
            if (ctx.request.method == "GET") {
                jsonResponse(ctx, service.listDepartments())
            } else if (ctx.request.method == "POST") {
                let form = parseBodyForm(readBody(ctx))
                let result = service.addDepartment(form.get("name") ?? "", form.get("description") ?? "")
                jsonResponse(ctx, result)
            } else if (ctx.request.method == "DELETE") {
                let id = parseInt64OrDefault(ctx.request.url.queryForm.get("id") ?? "0", 0)
                jsonResponse(ctx, service.deleteDepartment(id))
            } else {
                notAllowed(ctx)
            }
    })

    server.distributor.register("/api/employees", {
        ctx =>
            if (ctx.request.method == "GET") {
                let search = ctx.request.url.queryForm.get("search") ?? ""
                if (search.size > 0) {
                    jsonResponse(ctx, service.searchEmployees(search))
                } else {
                    jsonResponse(ctx, service.listEmployees())
                }
            } else if (ctx.request.method == "POST") {
                let form = parseBodyForm(readBody(ctx))
                let result = service.addEmployee(
                    form.get("name") ?? "",
                    form.get("email") ?? "",
                    form.get("phone") ?? "",
                    parseInt64OrDefault(form.get("department_id") ?? "0", 0),
                    form.get("position") ?? "",
                    form.get("salary") ?? "0"
                )
                jsonResponse(ctx, result)
            } else if (ctx.request.method == "PUT") {
                let form = parseBodyForm(readBody(ctx))
                let result = service.updateEmployee(
                    parseInt64OrDefault(form.get("id") ?? "0", 0),
                    form.get("name") ?? "",
                    form.get("email") ?? "",
                    form.get("phone") ?? "",
                    parseInt64OrDefault(form.get("department_id") ?? "0", 0),
                    form.get("position") ?? "",
                    form.get("salary") ?? "0"
                )
                jsonResponse(ctx, result)
            } else if (ctx.request.method == "DELETE") {
                let id = parseInt64OrDefault(ctx.request.url.queryForm.get("id") ?? "0", 0)
                jsonResponse(ctx, service.deleteEmployee(id))
            } else {
                notAllowed(ctx)
            }
    })

    server.distributor.register("/api/projects", {
        ctx =>
            if (ctx.request.method == "GET") {
                jsonResponse(ctx, service.listProjects())
            } else if (ctx.request.method == "POST") {
                let form = parseBodyForm(readBody(ctx))
                let result = service.addProject(
                    form.get("name") ?? "",
                    form.get("description") ?? "",
                    parseInt64OrDefault(form.get("department_id") ?? "0", 0),
                    form.get("budget") ?? "0"
                )
                jsonResponse(ctx, result)
            } else if (ctx.request.method == "DELETE") {
                let id = parseInt64OrDefault(ctx.request.url.queryForm.get("id") ?? "0", 0)
                jsonResponse(ctx, service.deleteProject(id))
            } else {
                notAllowed(ctx)
            }
    })

    server.distributor.register("/api/stats/departments", {
        ctx => jsonResponse(ctx, service.getDeptStats())
    })
    server.distributor.register("/api/stats/projects", {
        ctx => jsonResponse(ctx, service.getProjectStats())
    })
    server.distributor.register("/api/stats/salary-ranking", {
        ctx => jsonResponse(ctx, service.getSalaryRanking())
    })
    server.distributor.register("/api/logs", {
        ctx => jsonResponse(ctx, service.getRecentLogs())
    })
    server.distributor.register("/api/reviews", {
        ctx => jsonResponse(ctx, service.getPerformanceReviews())
    })
    server.distributor.register("/api/salary-history", {
        ctx => jsonResponse(ctx, service.getSalaryHistory())
    })
    server.distributor.register("/api/attendance", {
        ctx => jsonResponse(ctx, service.getAttendanceRecords())
    })
    server.distributor.register("/api/sql", {
        ctx =>
            if (ctx.request.method == "POST") {
                let form = parseBodyForm(readBody(ctx))
                jsonResponse(ctx, service.executeSql(form.get("sql") ?? ""))
            } else {
                notAllowed(ctx)
            }
    })

    println("Server starting on http://${bindAddr}:${serverPort}")
    server.serve()
}
