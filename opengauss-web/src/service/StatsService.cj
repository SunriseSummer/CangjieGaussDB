package opengauss_web.service

import opengauss_web.dao.*

public class StatsService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func deptStats(): String {
        return db.queryToJson(
            "SELECT d.name, COUNT(e.id)::text, "
            + "COALESCE(AVG(e.salary)::integer::text,'0'), "
            + "COALESCE(SUM(e.salary)::integer::text,'0') "
            + "FROM departments d LEFT JOIN employees e ON d.id=e.department_id "
            + "GROUP BY d.id,d.name ORDER BY d.name",
            [], ["department","employee_count","avg_salary","total_salary"]
        )
    }

    public func projectStats(): String {
        return db.queryToJson(
            "SELECT p.name, p.status, COALESCE(p.budget::text,'0'), "
            + "COUNT(pa.id)::text "
            + "FROM projects p LEFT JOIN project_assignments pa ON p.id=pa.project_id "
            + "GROUP BY p.id,p.name,p.status,p.budget ORDER BY p.name",
            [], ["project","status","budget","members"]
        )
    }

    public func salaryRanking(): String {
        return db.queryToJson(
            "SELECT e.name, COALESCE(e.position,''), COALESCE(d.name,''), "
            + "COALESCE(e.salary::text,'0'), "
            + "RANK() OVER(ORDER BY e.salary DESC)::text "
            + "FROM employees e LEFT JOIN departments d ON e.department_id=d.id "
            + "WHERE e.status='active' ORDER BY e.salary DESC",
            [], ["name","position","department","salary","rank"]
        )
    }
}
