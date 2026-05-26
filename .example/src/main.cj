package demo

import demo.service.*
import demo.dao.*
import std.random.*
import std.time.*
import std.math.numeric.*
import std.database.sql.*
import std.collection.concurrent.*
import std.collection.*
import opengauss.driver.*
import opengauss.slog.*
import stdx.logger.*
import stdx.log.*

const lockName = "lock-1"
const lockTableName = "lock_t"

const IdGeneratorTableName = "sequence_id_generator"
const bizType = 0

func setLogger() {
    let logger = Default()
    logger.level = LogLevel.ALL
}

main(): Unit {
    setLogger()

    testId()
}

func testId() {
    let set = ConcurrentHashMap<Int64, Int64>()
    let idGenerator = MultiGenerator("opengauss://gaussdb:Root%40123456@127.0.0.1:5432/omm?sslmode=disable", "opengauss", IdGeneratorTableName, 0, 2)
    let futs = ArrayList<Future<Unit>>()
    for (i in 0..10) {
        let fut = spawn {
            getId(idGenerator, set)
        }
        futs.add(fut)
    }
    for (fut in futs) {
        fut.get()
    }
    println("generated id: ${set.size}")
}

func getId(idGenerator: MultiGenerator, set: ConcurrentHashMap<Int64, Int64>) {
    let r = Random()
    for (i in 0..20) {
        let idx = r.nextInt64(idGenerator.size)
        let id = idGenerator.getId(idx)
        set.add(id, 0)
        print("${id} ")
    }
    println()
}

func testLock() {
    let logger = Default()
    let connector = Connector("opengauss://gaussdb:Root%40123456@127.0.0.1:5432/omm?sslmode=disable", "opengauss")
    let locker = Locker(connector, lockTableName)
    locker.unLock(lockName, "locker-1")
    locker.unLock(lockName, "locker-2")

    var fut2 =spawn { => 
        var me = "locker-2"
        if (locker.tryLock(lockName, me)) {
            logger.debug("${me} get lock")
        } else {
            logger.debug("${me} fail to get lock")
        }
    }

    var fut1 = spawn { => 
        var me = "locker-1"
        if (locker.tryLock(lockName, me)) {
            logger.debug("${me} get lock")
        } else {
            logger.debug("${me} fail to get lock")
        }
    }

    fut1.get()
    fut2.get()

    connector.close()
}