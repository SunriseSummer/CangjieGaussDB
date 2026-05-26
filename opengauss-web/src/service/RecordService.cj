package opengauss_web.service

import opengauss_web.dao.*

public class RecordService {
    private let db: DbConnector

    public init(db: DbConnector) {
        this.db = db
    }

    public func attendance(): String {
        return db.queryToJson(
            "SELECT a.id::text, e.name, COALESCE(a.check_in::text,''), "
            + "COALESCE(a.check_out::text,''), COALESCE(a.status,''), "
            + "COALESCE(a.record_date::text,'') "
            + "FROM attendance a JOIN employees e ON a.employee_id=e.id "
            + "ORDER BY a.record_date DESC, e.name",
            [], ["id","employee","check_in","check_out","status","record_date"]
        )
    }

    public func reviews(): String {
        return db.queryToJson(
            "SELECT pr.id::text, e.name, r.name, pr.score::text, "
            + "COALESCE(pr.comments,''), COALESCE(pr.review_period,'') "
            + "FROM performance_reviews pr "
            + "JOIN employees e ON pr.employee_id=e.id "
            + "JOIN employees r ON pr.reviewer_id=r.id "
            + "ORDER BY pr.created_at DESC",
            [], ["id","employee","reviewer","score","comments","period"]
        )
    }

    public func salaryHistory(): String {
        return db.queryToJson(
            "SELECT sh.id::text, e.name, COALESCE(sh.old_salary::text,''), "
            + "COALESCE(sh.new_salary::text,''), COALESCE(sh.change_reason,''), "
            + "COALESCE(sh.effective_date::text,'') "
            + "FROM salary_history sh JOIN employees e ON sh.employee_id=e.id "
            + "ORDER BY sh.effective_date DESC",
            [], ["id","employee","old_salary","new_salary","reason","effective_date"]
        )
    }

    public func logs(): String {
        return db.queryToJson(
            "SELECT id::text, COALESCE(table_name,''), COALESCE(operation,''), "
            + "COALESCE(record_id::text,''), COALESCE(details,''), operated_at::text "
            + "FROM operation_logs ORDER BY operated_at DESC LIMIT 50",
            [], ["id","table_name","operation","record_id","details","operated_at"]
        )
    }
}
