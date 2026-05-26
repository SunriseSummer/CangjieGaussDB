package opengauss_web.dao

import std.database.sql.*
import std.collection.*
import cangjie_tpc::opengauss.driver.*
import cangjie_tpc::opengauss.slog.*
import stdx.logger.*
import stdx.log.*

public class DbConnector {
    private var url: String
    private var driverStr: String

    public init(url: String) {
        this.url = url
        this.driverStr = "opengauss"
    }

    public func getConnection(): Connection {
        let driver = DriverManager.getDriver(driverStr).getOrThrow()
        let dataSource = driver.open(url, [])
        return dataSource.connect()
    }

    public func queryToJson(sqlStr: String, params: Array<Any>, columns: Array<String>): String {
        let conn = getConnection()
        try {
            let statement = conn.prepareStatement(sqlStr)
            try {
                for (i in 0..params.size) {
                    statement.set(i, params[i])
                }
                let result = statement.query()
                let sb = StringBuilder()
                sb.append("[")
                var firstRow = true
                while (result.next()) {
                    if (!firstRow) {
                        sb.append(",")
                    }
                    firstRow = false
                    sb.append("{")
                    for (j in 0..columns.size) {
                        if (j > 0) {
                            sb.append(",")
                        }
                        let colName = columns[j]
                        let value = result.getOrNull<String>(j) ?? ""
                        sb.append("\"")
                        sb.append(escapeJson(colName))
                        sb.append("\":\"")
                        sb.append(escapeJson(value))
                        sb.append("\"")
                    }
                    sb.append("}")
                }
                sb.append("]")
                return sb.toString()
            } finally {
                statement.close()
            }
        } finally {
            conn.close()
        }
    }

    public func execute(sqlStr: String, params: Array<Any>): Int64 {
        let conn = getConnection()
        try {
            let statement = conn.prepareStatement(sqlStr)
            try {
                for (i in 0..params.size) {
                    statement.set(i, params[i])
                }
                let result = statement.update()
                return result.rowCount
            } finally {
                statement.close()
            }
        } finally {
            conn.close()
        }
    }

    public func executeWithTransaction(statements: Array<(String, Array<Any>)>): Bool {
        let conn = getConnection()
        let transaction = conn.createTransaction()
        transaction.begin()
        try {
            for (item in statements) {
                let (sqlStr, params) = item
                let statement = conn.prepareStatement(sqlStr)
                try {
                    for (i in 0..params.size) {
                        statement.set(i, params[i])
                    }
                    statement.update()
                } finally {
                    statement.close()
                }
            }
            transaction.commit()
            return true
        } catch (e: Exception) {
            transaction.rollback()
            return false
        } finally {
            conn.close()
        }
    }
}

public func escapeJson(s: String): String {
    let sb = StringBuilder()
    for (c in s) {
        match (c) {
            case '"' => sb.append("\\\"")
            case '\\' => sb.append("\\\\")
            case '\n' => sb.append("\\n")
            case '\r' => sb.append("\\r")
            case '\t' => sb.append("\\t")
            case _ => sb.append(c.toString())
        }
    }
    return sb.toString()
}
