package opengauss_web.service

import opengauss_web.dao.*

let EMP_COLS = ["id","name","email","phone","department_id",
    "department","position","salary","hire_date","status"]

let EMP_SELECT =
    "SELECT e.id::text, e.name, e.email, COALESCE(e.phone,''), "
    + "COALESCE(e.department_id::text,''), COALESCE(d.name,''), "
    + "COALESCE(e.position,''), COALESCE(e.salary::text,''), "
    + "COALESCE(e.hire_date::text,''), COALESCE(e.status,'') "
    + "FROM employees e LEFT JOIN departments d ON e.department_id=d.id"

public class EmpService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func list(): String {
        return db.queryToJson("${EMP_SELECT} ORDER BY e.id", [], EMP_COLS)
    }

    public func search(keyword: String): String {
        let p = "%${keyword}%"
        return db.queryToJson(
            "${EMP_SELECT} WHERE e.name LIKE ? OR e.email LIKE ? OR e.position LIKE ? ORDER BY e.id",
            [p, p, p], EMP_COLS
        )
    }

    public func add(name: String, email: String, phone: String,
                    deptId: Int64, position: String, salary: String): String {
        let n = db.execute(
            "INSERT INTO employees(name,email,phone,department_id,position,salary,hire_date) "
            + "VALUES(?,?,?,?,?,?::decimal,CURRENT_DATE)",
            [name, email, phone, deptId, position, salary]
        )
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,details) VALUES('employees','INSERT',?)",
                ["Added employee: ${name}"]
            )
            return jsonOk("Employee added")
        }
        return jsonFail("Failed to add employee")
    }

    public func update(id: Int64, name: String, email: String, phone: String,
                       deptId: Int64, position: String, salary: String): String {
        let n = db.execute(
            "UPDATE employees SET name=?,email=?,phone=?,department_id=?,position=?,salary=?::decimal WHERE id=?",
            [name, email, phone, deptId, position, salary, id]
        )
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,record_id,details) VALUES('employees','UPDATE',?,?)",
                [id, "Updated: ${name}"]
            )
            return jsonOk("Employee updated")
        }
        return jsonFail("Employee not found")
    }

    public func delete(id: Int64): String {
        let n = db.execute("DELETE FROM employees WHERE id=?", [id])
        if (n > 0) {
            db.execute(
                "INSERT INTO operation_logs(table_name,operation,record_id,details) VALUES('employees','DELETE',?,'Deleted')",
                [id]
            )
            return jsonOk("Employee deleted")
        }
        return jsonFail("Employee not found")
    }
}
