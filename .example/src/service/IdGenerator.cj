package demo.service

import demo.dao.*
import std.sync.*
import std.collection.*
import std.collection.concurrent.*
import std.time.*
import stdx.logger.*
import stdx.log.*
import cangjie_tpc::opengauss.slog.*
import std.database.sql.*

// CREATE TABLE sequence_id_generator (
//    id serial PRIMARY KEY,
//    current_max_id bigint NOT NULL,
//    step integer NOT NULL,
//    biz_type integer NOT NULL UNIQUE
// );

// COMMENT ON COLUMN sequence_id_generator.current_max_id IS '当前最大id';
// COMMENT ON COLUMN sequence_id_generator.step IS '号段的长度';
// COMMENT ON COLUMN sequence_id_generator.biz_type IS '业务类型';

public class IdGenerator {
    private static let step = 100 // 和数据库配置的step需要一致

    private static let slotSize = 10

    private static let threshold = 4 // 每次计算会 /10  相当于0.4

    private var isSupplement = AtomicBool(false)

    private var id = AtomicInt64(0)

    private var min = 0

    private var max = 0

    private var logger: Logger = Default()

    public IdGenerator(
        private var url: String,
        private var driverStr: String,
        private var tableName: String, 
        private var bizType: Int64
    ) {
        supplementId(true) // 启动的时候先获取id 防止服务正式启动阻塞用户线程
    }

    public func getId() {
        var returnId = id.fetchAdd(1)
        var trySupplement = false
        while (true) {
            if (!trySupplement && max - returnId <= step * threshold / 10) {
                // 尝试异步补充ID
                trySupplement = true
                spawn { supplementId(false) }
            }
            while (returnId < min) {
                // MultiGenerator模式下 该操作是必要的 但是会造成性能下降 可以考虑其他方式（比如错位取号）解决防止重复ID
                returnId = id.fetchAdd(1)
            } 
            if (returnId < max && returnId >= min) {
                return returnId
            }
            sleep(100 * Duration.millisecond)
            
        }
        // never
        return -1
    }

    private func supplementId(isFirst: Bool) {
        // 原子bool模拟信号量 同一时间只有一个线程加载ID
        if (!isSupplement.compareAndSwap(false, true)|| !canSupplement()) { 
            return 
        }
        var fromToTuple = getIdsFromDB()
        if (isFirst) { 
            id.store(fromToTuple[0])
        }
        min = fromToTuple[0]
        max = fromToTuple[1]
        isSupplement.store(false)
    }

    private func canSupplement() {
        max - id.load() <= step * threshold / 10
    }

    private func getIdsFromDB() {
        let connector = Connector(url, driverStr)
        let transaction = connector.conn.createTransaction()
        transaction.begin()

        try {
            var selectSql = "select id, current_max_id, step from ${tableName} where biz_type = ? for update"
            var result = connector.select(selectSql, [bizType])
            if (result.next()) {
                if (result.get<Int64>(2) != step) {
                    throw Exception("The step size is inconsistent with the step in database")
                }
                var updateSql = "update ${tableName} set current_max_id = current_max_id + step where id = ? and biz_type = ?"
                connector.update(updateSql, [result.get<Int64>(0), bizType])
                var from= result.get<Int64>(1)
                var to = from + step
                return (from, to)
            } else {
                logger.info("There is no corresponding business. Try to create a new Id table")
                var insertSql = "INSERT INTO ${tableName} (current_max_id, step, biz_type) VALUES (?, ?, ?)"
                connector.update(insertSql, [step, step, bizType])
                return (0, step)
            }
        } finally {
            transaction.commit()
            connector.close()
        }
    }

    private func hash(id: Int64) {
        id % slotSize
    }
}