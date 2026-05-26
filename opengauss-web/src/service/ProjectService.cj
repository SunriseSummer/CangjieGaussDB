package opengauss_web.service

import opengauss_web.dao.*

public class ProjectService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func list(): String {
        return db.queryToJson(
            "SELECT p.id::text, p.name, COALESCE(p.description,''), "
            + "COALESCE(p.department_id::text,''), COALESCE(d.name,''), "
            + "COALESCE(p.start_date::text,''), COALESCE(p.end_date::text,''), "
            + "COALESCE(p.budget::text,''), COALESCE(p.status,'') "
            + "FROM projects p LEFT JOIN departments d ON p.department_id=d.id ORDER BY p.id",
            [], ["id","name","description","department_id","department",
                 "start_date","end_date","budget","status"]
        )
    }

    public func add(name: String, desc: String, deptId: Int64, budget: String): String {
        let n = db.execute(
            "INSERT INTO projects(name,description,department_id,start_date,budget,status) "
            + "VALUES(?,?,?,CURRENT_DATE,?::decimal,'planning')",
            [name, desc, deptId, budget]
        )
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,details) VALUES('projects','INSERT',?)",
                ["Added project: ${name}"]
            )
            return jsonOk("Project added")
        }
        return jsonFail("Failed to add project")
    }

    public func updateStatus(id: Int64, status: String): String {
        let n = db.execute("UPDATE projects SET status=? WHERE id=?", [status, id])
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,record_id,details) VALUES('projects','UPDATE',?,?)",
                [id, "Status → ${status}"]
            )
            return jsonOk("Project status updated")
        }
        return jsonFail("Project not found")
    }

    public func delete(id: Int64): String {
        db.execute("DELETE FROM project_assignments WHERE project_id=?", [id])
        let n = db.execute("DELETE FROM projects WHERE id=?", [id])
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,record_id,details) VALUES('projects','DELETE',?,'Deleted')",
                [id]
            )
            return jsonOk("Project deleted")
        }
        return jsonFail("Project not found")
    }
}
