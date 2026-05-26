package opengauss_web.service

import opengauss_web.dao.*

public class DeptService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func list(): String {
        return db.queryToJson(
            "SELECT d.id::text, d.name, COALESCE(d.description,''), "
            + "COALESCE(d.manager_id::text,''), COALESCE(e.name,'') AS manager_name, "
            + "d.created_at::text "
            + "FROM departments d LEFT JOIN employees e ON d.manager_id=e.id ORDER BY d.id",
            [], ["id","name","description","manager_id","manager_name","created_at"]
        )
    }

    public func add(name: String, description: String): String {
        let n = db.execute(
            "INSERT INTO departments(name,description) VALUES(?,?)",
            [name, description]
        )
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,details) VALUES('departments','INSERT',?)",
                ["Added department: ${name}"]
            )
            return jsonOk("Department added")
        }
        return jsonFail("Failed to add department")
    }

    public func delete(id: Int64): String {
        let n = db.execute("DELETE FROM departments WHERE id=?", [id])
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,record_id,details) VALUES('departments','DELETE',?,'Deleted')",
                [id]
            )
            return jsonOk("Department deleted")
        }
        return jsonFail("Department not found")
    }
}
