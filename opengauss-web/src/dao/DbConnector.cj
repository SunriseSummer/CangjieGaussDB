package opengauss_web.dao

import std.database.sql.*
import std.collection.*
import cangjie_tpc::opengauss.driver.*

public class DbConnector {
    private let url: String

    public init(url: String) {
        this.url = url
    }

    public func getConnection(): Connection {
        let driver = DriverManager.getDriver("opengauss").getOrThrow()
        return driver.open(url, []).connect()
    }

    public func queryToJson(
        sqlStr: String,
        params: Array<Any>,
        columns: Array<String>
    ): String {
        let conn = getConnection()
        try {
            let stmt = conn.prepareStatement(sqlStr)
            try {
                for (i in 0..params.size) {
                    stmt.set(i, params[i])
                }
                let rs = stmt.query()
                let sb = StringBuilder()
                sb.append("[")
                var first = true
                while (rs.next()) {
                    if (!first) { sb.append(",") }
                    first = false
                    sb.append("{")
                    for (j in 0..columns.size) {
                        if (j > 0) { sb.append(",") }
                        sb.append("\"${escapeJson(columns[j])}\":")
                        sb.append("\"${escapeJson(rs.getOrNull<String>(j) ?? "")}\"")
                    }
                    sb.append("}")
                }
                sb.append("]")
                return sb.toString()
            } finally {
                stmt.close()
            }
        } finally {
            conn.close()
        }
    }

    public func execute(sqlStr: String, params: Array<Any>): Int64 {
        let conn = getConnection()
        try {
            let stmt = conn.prepareStatement(sqlStr)
            try {
                for (i in 0..params.size) {
                    stmt.set(i, params[i])
                }
                return stmt.update().rowCount
            } finally {
                stmt.close()
            }
        } finally {
            conn.close()
        }
    }

    public func executeBatch(stmts: Array<(String, Array<Any>)>): Bool {
        let conn = getConnection()
        let tx = conn.createTransaction()
        tx.begin()
        try {
            for (item in stmts) {
                let (sqlStr, params) = item
                let stmt = conn.prepareStatement(sqlStr)
                try {
                    for (i in 0..params.size) {
                        stmt.set(i, params[i])
                    }
                    stmt.update()
                } finally {
                    stmt.close()
                }
            }
            tx.commit()
            return true
        } catch (_: Exception) {
            tx.rollback()
            return false
        } finally {
            conn.close()
        }
    }
}
