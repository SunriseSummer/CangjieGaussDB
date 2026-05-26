package demo.service

import demo.dao.*
import std.time.*
import std.math.numeric.*
import std.database.sql.*
import opengauss.driver.*
import opengauss.slog.*
import stdx.logger.*
import stdx.log.*

// 支持多IdGenerator并行 防止原子整数单点成为性能瓶颈
public class MultiGenerator {

    private var idGens: Array<IdGenerator>

    public MultiGenerator(
        private var url: String,
        private var driverStr: String,
        private var tableName: String, 
        private var bizType: Int64,
        public var size: Int64 // 暴露给客户端 方便客户端做hash路由
    ) {
        idGens = Array<IdGenerator>(size, { i => IdGenerator(url, driverStr, tableName, bizType) })
    }

    public func getId(idx: Int64) {
        let idGen = idGens[idx]
        idGen.getId()
    }
}