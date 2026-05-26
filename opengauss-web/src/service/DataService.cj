package opengauss_web.service

import opengauss_web.dao.*
import std.collection.*
import std.unicode.*

public class DataService {
    private var db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func listDepartments(): String {
        return db.queryToJson(
            "SELECT d.id::text, d.name, COALESCE(d.description, ''), COALESCE(d.manager_id::text, ''), COALESCE(e.name, '') as manager_name, d.created_at::text FROM departments d LEFT JOIN employees e ON d.manager_id = e.id ORDER BY d.id",
            [],
            ["id", "name", "description", "manager_id", "manager_name", "created_at"]
        )
    }

    public func addDepartment(name: String, description: String): String {
        let rows = db.execute(
            "INSERT INTO departments (name, description) VALUES (?, ?)",
            [name, description]
        )
        if (rows > 0) {
            db.execute("INSERT INTO operation_logs (table_name, operation, details) VALUES ('departments', 'INSERT', ?)", ["Added department: " + name])
            return ok("Department added successfully")
        }
        return fail("Failed to add department")
    }

    public func deleteDepartment(id: Int64): String {
        let rows = db.execute("DELETE FROM departments WHERE id = ?", [id])
        if (rows > 0) {
            db.execute("INSERT INTO operation_logs (table_name, operation, record_id, details) VALUES ('departments', 'DELETE', ?, 'Department deleted')", [id])
            return ok("Department deleted")
        }
        return fail("Failed to delete department")
    }

    public func listEmployees(): String {
        return db.queryToJson(
            "SELECT e.id::text, e.name, e.email, COALESCE(e.phone, ''), COALESCE(e.department_id::text, ''), COALESCE(d.name, '') as dept_name, COALESCE(e.position, ''), COALESCE(e.salary::text, ''), COALESCE(e.hire_date::text, ''), COALESCE(e.status, '') FROM employees e LEFT JOIN departments d ON e.department_id = d.id ORDER BY e.id",
            [],
            ["id", "name", "email", "phone", "department_id", "department", "position", "salary", "hire_date", "status"]
        )
    }

    public func addEmployee(name: String, email: String, phone: String, deptId: Int64, position: String, salary: String): String {
        let rows = db.execute(
            "INSERT INTO employees (name, email, phone, department_id, position, salary, hire_date) VALUES (?, ?, ?, ?, ?, ?::decimal, CURRENT_DATE)",
            [name, email, phone, deptId, position, salary]
        )
        if (rows > 0) {
            db.execute("INSERT INTO operation_logs (table_name, operation, details) VALUES ('employees', 'INSERT', ?)", ["Added employee: " + name])
            return ok("Employee added successfully")
        }
        return fail("Failed to add employee")
    }

    public func updateEmployee(id: Int64, name: String, email: String, phone: String, deptId: Int64, position: String, salary: String): String {
        let rows = db.execute(
            "UPDATE employees SET name = ?, email = ?, phone = ?, department_id = ?, position = ?, salary = ?::decimal WHERE id = ?",
            [name, email, phone, deptId, position, salary, id]
        )
        if (rows > 0) {
            db.execute("INSERT INTO operation_logs (table_name, operation, record_id, details) VALUES ('employees', 'UPDATE', ?, ?)", [id, "Updated employee: " + name])
            return ok("Employee updated")
        }
        return fail("Failed to update employee")
    }

    public func deleteEmployee(id: Int64): String {
        let rows = db.execute("DELETE FROM employees WHERE id = ?", [id])
        if (rows > 0) {
            db.execute("INSERT INTO operation_logs (table_name, operation, record_id, details) VALUES ('employees', 'DELETE', ?, 'Employee deleted')", [id])
            return ok("Employee deleted")
        }
        return fail("Failed to delete employee")
    }

    public func searchEmployees(keyword: String): String {
        let pattern = "%" + keyword + "%"
        return db.queryToJson(
            "SELECT e.id::text, e.name, e.email, COALESCE(e.phone, ''), COALESCE(e.department_id::text, ''), COALESCE(d.name, '') as dept_name, COALESCE(e.position, ''), COALESCE(e.salary::text, ''), COALESCE(e.hire_date::text, ''), COALESCE(e.status, '') FROM employees e LEFT JOIN departments d ON e.department_id = d.id WHERE e.name LIKE ? OR e.email LIKE ? OR e.position LIKE ? ORDER BY e.id",
            [pattern, pattern, pattern],
            ["id", "name", "email", "phone", "department_id", "department", "position", "salary", "hire_date", "status"]
        )
    }

    public func listProjects(): String {
        return db.queryToJson(
            "SELECT p.id::text, p.name, COALESCE(p.description, ''), COALESCE(p.department_id::text, ''), COALESCE(d.name, '') as dept_name, COALESCE(p.start_date::text, ''), COALESCE(p.end_date::text, ''), COALESCE(p.budget::text, ''), COALESCE(p.status, '') FROM projects p LEFT JOIN departments d ON p.department_id = d.id ORDER BY p.id",
            [],
            ["id", "name", "description", "department_id", "department", "start_date", "end_date", "budget", "status"]
        )
    }

    public func addProject(name: String, description: String, deptId: Int64, budget: String): String {
        let rows = db.execute(
            "INSERT INTO projects (name, description, department_id, start_date, budget, status) VALUES (?, ?, ?, CURRENT_DATE, ?::decimal, 'planning')",
            [name, description, deptId, budget]
        )
        if (rows > 0) {
            db.execute("INSERT INTO operation_logs (table_name, operation, details) VALUES ('projects', 'INSERT', ?)", ["Added project: " + name])
            return ok("Project added successfully")
        }
        return fail("Failed to add project")
    }

    public func deleteProject(id: Int64): String {
        db.execute("DELETE FROM project_assignments WHERE project_id = ?", [id])
        let rows = db.execute("DELETE FROM projects WHERE id = ?", [id])
        if (rows > 0) {
            db.execute("INSERT INTO operation_logs (table_name, operation, record_id, details) VALUES ('projects', 'DELETE', ?, 'Project deleted')", [id])
            return ok("Project deleted")
        }
        return fail("Failed to delete project")
    }

    public func getDeptStats(): String {
        return db.queryToJson(
            "SELECT d.name, COUNT(e.id)::text as emp_count, COALESCE(AVG(e.salary)::integer::text, '0') as avg_salary, COALESCE(SUM(e.salary)::integer::text, '0') as total_salary FROM departments d LEFT JOIN employees e ON d.id = e.department_id GROUP BY d.id, d.name ORDER BY d.name",
            [],
            ["department", "employee_count", "avg_salary", "total_salary"]
        )
    }

    public func getProjectStats(): String {
        return db.queryToJson(
            "SELECT p.name, p.status, COALESCE(p.budget::text, '0'), COUNT(pa.id)::text as member_count FROM projects p LEFT JOIN project_assignments pa ON p.id = pa.project_id GROUP BY p.id, p.name, p.status, p.budget ORDER BY p.name",
            [],
            ["project", "status", "budget", "members"]
        )
    }

    public func getSalaryRanking(): String {
        return db.queryToJson(
            "SELECT e.name, COALESCE(e.position, ''), COALESCE(d.name, '') as dept_name, COALESCE(e.salary::text, '0'), RANK() OVER (ORDER BY e.salary DESC)::text as ranking FROM employees e LEFT JOIN departments d ON e.department_id = d.id WHERE e.status = 'active' ORDER BY e.salary DESC",
            [],
            ["name", "position", "department", "salary", "rank"]
        )
    }

    public func getRecentLogs(): String {
        return db.queryToJson(
            "SELECT id::text, COALESCE(table_name, ''), COALESCE(operation, ''), COALESCE(record_id::text, ''), COALESCE(details, ''), operated_at::text FROM operation_logs ORDER BY operated_at DESC LIMIT 20",
            [],
            ["id", "table_name", "operation", "record_id", "details", "operated_at"]
        )
    }

    public func getPerformanceReviews(): String {
        return db.queryToJson(
            "SELECT pr.id::text, e.name as employee, r.name as reviewer, pr.score::text, COALESCE(pr.comments, ''), COALESCE(pr.review_period, '') FROM performance_reviews pr JOIN employees e ON pr.employee_id = e.id JOIN employees r ON pr.reviewer_id = r.id ORDER BY pr.created_at DESC",
            [],
            ["id", "employee", "reviewer", "score", "comments", "period"]
        )
    }

    public func getSalaryHistory(): String {
        return db.queryToJson(
            "SELECT sh.id::text, e.name, COALESCE(sh.old_salary::text, ''), COALESCE(sh.new_salary::text, ''), COALESCE(sh.change_reason, ''), COALESCE(sh.effective_date::text, '') FROM salary_history sh JOIN employees e ON sh.employee_id = e.id ORDER BY sh.effective_date DESC",
            [],
            ["id", "employee", "old_salary", "new_salary", "reason", "effective_date"]
        )
    }

    public func getAttendanceRecords(): String {
        return db.queryToJson(
            "SELECT a.id::text, e.name, COALESCE(a.check_in::text, ''), COALESCE(a.check_out::text, ''), COALESCE(a.status, ''), COALESCE(a.record_date::text, '') FROM attendance a JOIN employees e ON a.employee_id = e.id ORDER BY a.record_date DESC, e.name",
            [],
            ["id", "employee", "check_in", "check_out", "status", "record_date"]
        )
    }

    // Execute a user-provided SQL query in the SQL console.
    // Security: only SELECT statements are allowed; isSelectQuery() strips leading
    // whitespace/comments and rejects anything that is not a single SELECT statement
    // (multi-statement via semicolons is also rejected).
    public func executeSql(sqlStr: String): String {
        if (!isSelectQuery(sqlStr)) {
            return "{\"error\":\"Only SELECT queries are allowed in SQL console\"}"
        }
        let conn = db.getConnection()
        try {
            let statement = conn.prepareStatement(sqlStr)
            try {
                let result = statement.query()
                let sb = StringBuilder()
                sb.append("[")
                var first = true
                var rowCount = 0
                // Limit to 100 rows to prevent excessive memory usage in the browser
                while (result.next() && rowCount < 100) {
                    if (!first) {
                        sb.append(",")
                    }
                    first = false
                    let colVals = StringBuilder()
                    // Display up to the first 10 columns per row (UI constraint)
                    for (k in 0..10) {
                        try {
                            let v = result.getOrNull<String>(k) ?? ""
                            if (v.size > 0) {
                                if (colVals.toString().size > 0) {
                                    colVals.append(" | ")
                                }
                                colVals.append(escapeJson(v))
                            }
                        } catch (_: Exception) {
                            break
                        }
                    }
                    sb.append("{\"row\":\"")
                    sb.append(colVals.toString())
                    sb.append("\"}")
                    rowCount += 1
                }
                sb.append("]")
                return sb.toString()
            } finally {
                statement.close()
            }
        } catch (e: Exception) {
            return "{\"error\":\"" + escapeJson(e.message) + "\"}"
        } finally {
            conn.close()
        }
    }
}

func ok(message: String): String {
    return "{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}"
}

func fail(message: String): String {
    return "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}"
}

func upperAscii(b: UInt8): UInt8 {
    if (b >= 97 && b <= 122) {
        return b - 32
    }
    return b
}

func isWhitespaceByte(b: UInt8): Bool {
    return b == 32 || b == 9 || b == 10 || b == 13
}

func skipPrefixNoise(bytes: Array<UInt8>): Int64 {
    var index: Int64 = 0
    while (index < bytes.size) {
        while (index < bytes.size && isWhitespaceByte(bytes[index])) {
            index += 1
        }
        if (index + 1 < bytes.size && bytes[index] == 47 && bytes[index + 1] == 42) {
            index += 2
            while (index + 1 < bytes.size && !(bytes[index] == 42 && bytes[index + 1] == 47)) {
                index += 1
            }
            if (index + 1 < bytes.size) {
                index += 2
            }
            continue
        }
        if (index + 1 < bytes.size && bytes[index] == 45 && bytes[index + 1] == 45) {
            index += 2
            while (index < bytes.size && bytes[index] != 10) {
                index += 1
            }
            continue
        }
        break
    }
    return index
}

func hasTrailingStatement(bytes: Array<UInt8>): Bool {
    var seenSemicolon = false
    for (i in 0..bytes.size) {
        if (bytes[i] == 59) {
            seenSemicolon = true
        } else if (seenSemicolon && !isWhitespaceByte(bytes[i])) {
            return true
        }
    }
    return false
}

func isSelectQuery(sqlStr: String): Bool {
    let bytes = sqlStr.toArray()
    let start = skipPrefixNoise(bytes)
    let preview = bytes[start..bytes.size]
    if (preview.size < 6 || hasTrailingStatement(preview)) {
        return false
    }
    return upperAscii(preview[0]) == 83 &&
        upperAscii(preview[1]) == 69 &&
        upperAscii(preview[2]) == 76 &&
        upperAscii(preview[3]) == 69 &&
        upperAscii(preview[4]) == 67 &&
        upperAscii(preview[5]) == 84
}
