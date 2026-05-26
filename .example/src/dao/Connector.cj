package demo.dao

import std.time.*
import std.database.sql.*
import opengauss.driver.*
import opengauss.slog.*
import stdx.logger.*
import stdx.log.*

public class Connector {
    public var conn: Connection

    public Connector(var url: String, var driverStr: String) {
        var driver = DriverManager.getDriver(driverStr).getOrThrow()
        var dataSource = driver.open(url)
	    conn = dataSource.connect()
    }

    public func select(sqlStr: String, values: Array<Any>) {
        var statement = conn.prepareStatement(sqlStr)
        try {
            for (i in 0..values.size) {
                statement.set(i + 1, values[i])
            }
            return statement.query()
        } finally {
            statement.close()
        }
    }

    public func update(sqlStr: String, values: Array<Any>) {
        var statement = conn.prepareStatement(sqlStr)
        try {
            for (i in 0..values.size) {
                statement.set(i + 1, values[i])
            }
            return statement.update()
        } finally {
            statement.close()
        }
    }

    public func close() {
        conn.close()
    }
}