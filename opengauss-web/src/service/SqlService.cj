package opengauss_web.service

import opengauss_web.dao.*
import opengauss_web.util.*

public class SqlService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    // Only SELECT queries are allowed. Validates and limits to 100 rows / 10 cols.
    public func execute(sqlStr: String): String {
        if (!isSelectQuery(sqlStr)) {
            return "{\"error\":\"Only SELECT queries are allowed\"}"
        }
        let conn = db.getConnection()
        try {
            let stmt = conn.prepareStatement(sqlStr)
            try {
                let rs = stmt.query()
                let sb = StringBuilder()
                sb.append("[")
                var first = true
                var rows = 0
                while (rs.next() && rows < 100) {
                    if (!first) { sb.append(",") }
                    first = false
                    let vals = StringBuilder()
                    for (k in 0..10) {
                        try {
                            let v = rs.getOrNull<String>(k) ?? ""
                            if (v.size > 0) {
                                if (vals.toString().size > 0) { vals.append(" | ") }
                                vals.append(escapeJson(v))
                            }
                        } catch (_: Exception) {
                            break
                        }
                    }
                    sb.append("{\"row\":\"${vals.toString()}\"}")
                    rows += 1
                }
                sb.append("]")
                return sb.toString()
            } finally {
                stmt.close()
            }
        } catch (e: Exception) {
            return "{\"error\":\"${escapeJson(e.message)}\"}"
        } finally {
            conn.close()
        }
    }
}
