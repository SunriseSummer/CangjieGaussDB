package opengauss_web.service

import opengauss_web.dao.*
import opengauss_web.util.*

public class AdvancedService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func listViews(): String {
        return db.queryToJson(
            "SELECT viewname, definition FROM pg_views "
            + "WHERE schemaname='public' ORDER BY viewname",
            [], ["name","definition"]
        )
    }

    public func createView(name: String, query: String): String {
        if (!isIdentifier(name)) {
            return jsonFail("Invalid view name")
        }
        try {
            db.execute("CREATE OR REPLACE VIEW ${name} AS ${query}", [])
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,details) VALUES('views','CREATE',?)",
                ["Created view: ${name}"]
            )
            return jsonOk("View '${name}' created")
        } catch (e: Exception) {
            return jsonFail(e.message)
        }
    }

    public func listIndexes(): String {
        return db.queryToJson(
            "SELECT indexname, tablename, indexdef "
            + "FROM pg_indexes WHERE schemaname='public' ORDER BY tablename, indexname",
            [], ["name","table","definition"]
        )
    }

    public func createIndex(table: String, column: String): String {
        if (!isIdentifier(table) || !isIdentifier(column)) {
            return jsonFail("Invalid table or column name")
        }
        let idxName = "idx_${table}_${column}"
        try {
            db.execute("CREATE INDEX ${idxName} ON ${table}(${column})", [])
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,details) VALUES('indexes','CREATE',?)",
                ["Created index: ${idxName}"]
            )
            return jsonOk("Index '${idxName}' created")
        } catch (e: Exception) {
            return jsonFail(e.message)
        }
    }

    public func batchInsert(data: Array<(String, String, Int64)>): String {
        let stmts = Array<(String, Array<Any>)>(data.size) {
            i =>
            let (name, email, deptId) = data[i]
            ("INSERT INTO employees(name,email,department_id,position,salary,hire_date,status) "
             + "VALUES(?,?,?,'Staff',10000,CURRENT_DATE,'active')",
             [name, email, deptId])
        }
        if (db.executeBatch(stmts)) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,details) VALUES('employees','BATCH_INSERT',?)",
                ["Batch inserted ${data.size} employees"]
            )
            return jsonOk("Batch inserted ${data.size} employees")
        }
        return jsonFail("Batch insert failed (rolled back)")
    }

    public func transfer(fromId: Int64, toId: Int64, amount: String): String {
        let stmts: Array<(String, Array<Any>)> = [
            ("UPDATE employees SET salary=salary-?::decimal WHERE id=?", [amount, fromId]),
            ("UPDATE employees SET salary=salary+?::decimal WHERE id=?", [amount, toId])
        ]
        if (db.executeBatch(stmts)) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,details) VALUES('employees','TRANSFER',?)",
                ["Transfer ${amount} from #${fromId} to #${toId}"]
            )
            return jsonOk("Transfer completed")
        }
        return jsonFail("Transfer failed (rolled back)")
    }

    public func aggregates(): String {
        return db.queryToJson(
            "SELECT COUNT(*)::text, "
            + "COALESCE(MIN(salary)::text,'0'), COALESCE(MAX(salary)::text,'0'), "
            + "COALESCE(AVG(salary)::integer::text,'0'), COALESCE(SUM(salary)::integer::text,'0'), "
            + "COALESCE(STDDEV(salary)::integer::text,'0') "
            + "FROM employees WHERE status='active'",
            [], ["count","min","max","avg","sum","stddev"]
        )
    }

    public func subquery(): String {
        return db.queryToJson(
            "SELECT e.name, COALESCE(e.salary::text,'0'), COALESCE(d.name,'') "
            + "FROM employees e JOIN departments d ON e.department_id=d.id "
            + "WHERE e.salary > (SELECT AVG(salary) FROM employees WHERE status='active') "
            + "ORDER BY e.salary DESC",
            [], ["name","salary","department"]
        )
    }
}
