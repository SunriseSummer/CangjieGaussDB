package demo.service

import demo.dao.*
import std.time.*
import stdx.logger.*
import stdx.log.*
import cangjie_tpc::opengauss.slog.*
import std.database.sql.*

// CREATE TABLE lock_t (
//     lock_name VARCHAR(255) PRIMARY KEY, -- 锁的名称，确保每个锁是唯一的
//     locked BOOLEAN NOT NULL,            -- 锁是否被占用
//     locked_at TIMESTAMPTZ DEFAULT NOW(), -- 锁被占用的时间戳
//     locked_by VARCHAR(255)              -- 锁被哪个客户端/进程占用
// );

public class Locker {
    var logger: Logger

    public Locker(var connector: Connector, var tableName: String) {
        logger = Default()
    }

    private func addLock(lockName: String, lockedBy: String) {
        let sqlInsert = "insert into ${tableName} (lock_name, locked, locked_at, locked_by) values(?, ?, ?, ?)"
        connector.update(sqlInsert, [lockName, true,  DateTime.now(), lockedBy])
    }

    public func tryLock(lockName: String, lockedBy: String): Bool {
        var transaction = connector.conn.createTransaction()
        transaction.begin()
        try {
            let sqlSelect = "select locked, locked_by from ${tableName} where lock_name = ? for update"
            var result = connector.select(sqlSelect, [lockName])
            if (result.next() && (result.getOrNull<Bool>(0) ?? false)) {
                if (result.get<String>(1) != lockedBy) {
                    return false
                }
            }
            addLock(lockName, lockedBy)
            return true
        } catch (e: Exception) {
            logger.debug("Exception: ${e.toString()}")
            var sqlDelete = "delete from ${tableName} where lock_name = ? and locked_by = ?"
            connector.update(sqlDelete, [lockName, lockedBy])
            return false
        } finally {
            transaction.commit()
        }
    }

    public func unLock(lockName: String, lockeBy: String) {
        var sqlDelete = "delete from ${tableName} where lock_name = ? and locked_by = ?"
        connector.update(sqlDelete, [lockName, lockeBy])
    }
}