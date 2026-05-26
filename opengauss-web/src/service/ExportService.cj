package opengauss_web.service

import opengauss_web.dao.*

public class ExportService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func employeesCsv(): String {
        let conn = db.getConnection()
        try {
            let stmt = conn.prepareStatement(
                "SELECT e.id, e.name, e.email, COALESCE(e.phone,''), "
                + "COALESCE(d.name,''), COALESCE(e.position,''), "
                + "COALESCE(e.salary::text,''), COALESCE(e.hire_date::text,''), "
                + "COALESCE(e.status,'') "
                + "FROM employees e LEFT JOIN departments d ON e.department_id=d.id ORDER BY e.id"
            )
            try {
                let rs = stmt.query()
                let sb = StringBuilder()
                sb.append("ID,Name,Email,Phone,Department,Position,Salary,HireDate,Status\n")
                while (rs.next()) {
                    for (j in 0..9) {
                        if (j > 0) { sb.append(",") }
                        let v = rs.getOrNull<String>(j) ?? ""
                        sb.append("\"${escapeJson(v)}\"")
                    }
                    sb.append("\n")
                }
                return sb.toString()
            } finally {
                stmt.close()
            }
        } finally {
            conn.close()
        }
    }

    public func deptStatsCsv(): String {
        let conn = db.getConnection()
        try {
            let stmt = conn.prepareStatement(
                "SELECT d.name, COUNT(e.id)::text, "
                + "COALESCE(AVG(e.salary)::integer::text,'0'), "
                + "COALESCE(SUM(e.salary)::integer::text,'0') "
                + "FROM departments d LEFT JOIN employees e ON d.id=e.department_id "
                + "GROUP BY d.id,d.name ORDER BY d.name"
            )
            try {
                let rs = stmt.query()
                let sb = StringBuilder()
                sb.append("Department,Employees,AvgSalary,TotalSalary\n")
                while (rs.next()) {
                    for (j in 0..4) {
                        if (j > 0) { sb.append(",") }
                        let v = rs.getOrNull<String>(j) ?? ""
                        sb.append("\"${escapeJson(v)}\"")
                    }
                    sb.append("\n")
                }
                return sb.toString()
            } finally {
                stmt.close()
            }
        } finally {
            conn.close()
        }
    }
}
