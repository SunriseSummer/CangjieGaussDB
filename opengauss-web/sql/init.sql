-- Employee Management System Tables

CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department_id INTEGER REFERENCES departments(id),
    position VARCHAR(100),
    salary DECIMAL(10, 2),
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    department_id INTEGER REFERENCES departments(id),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12, 2),
    status VARCHAR(20) DEFAULT 'planning',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS project_assignments (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id),
    project_id INTEGER REFERENCES projects(id),
    role VARCHAR(50),
    assigned_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id),
    check_in TIMESTAMP,
    check_out TIMESTAMP,
    status VARCHAR(20) DEFAULT 'present',
    record_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS performance_reviews (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id),
    reviewer_id INTEGER REFERENCES employees(id),
    score INTEGER CHECK(score >= 1 AND score <= 5),
    comments TEXT,
    review_period VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS salary_history (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id),
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    change_reason VARCHAR(200),
    effective_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS operation_logs (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation VARCHAR(20),
    record_id INTEGER,
    details TEXT,
    operated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO departments (name, description) VALUES
    ('Engineering', 'Software Engineering Department'),
    ('Marketing', 'Marketing and Communications'),
    ('Finance', 'Financial Planning and Analysis'),
    ('HR', 'Human Resources Management'),
    ('Operations', 'Business Operations');

INSERT INTO employees (name, email, phone, department_id, position, salary, hire_date, status) VALUES
    ('Zhang Wei', 'zhang.wei@example.com', '13800001001', 1, 'Senior Engineer', 25000.00, '2020-03-15', 'active'),
    ('Li Na', 'li.na@example.com', '13800001002', 1, 'Tech Lead', 35000.00, '2019-06-01', 'active'),
    ('Wang Fang', 'wang.fang@example.com', '13800001003', 2, 'Marketing Manager', 28000.00, '2020-01-10', 'active'),
    ('Chen Ming', 'chen.ming@example.com', '13800001004', 3, 'Financial Analyst', 22000.00, '2021-07-20', 'active'),
    ('Liu Yang', 'liu.yang@example.com', '13800001005', 1, 'Junior Engineer', 15000.00, '2022-09-01', 'active'),
    ('Zhao Lei', 'zhao.lei@example.com', '13800001006', 4, 'HR Specialist', 18000.00, '2021-03-15', 'active'),
    ('Sun Jie', 'sun.jie@example.com', '13800001007', 5, 'Operations Lead', 26000.00, '2020-08-10', 'active'),
    ('Zhou Xin', 'zhou.xin@example.com', '13800001008', 2, 'Content Creator', 16000.00, '2022-05-20', 'active'),
    ('Wu Gang', 'wu.gang@example.com', '13800001009', 1, 'DevOps Engineer', 30000.00, '2019-11-01', 'active'),
    ('Huang Ying', 'huang.ying@example.com', '13800001010', 3, 'Senior Accountant', 24000.00, '2020-04-15', 'active');

UPDATE departments SET manager_id = 2 WHERE id = 1;
UPDATE departments SET manager_id = 3 WHERE id = 2;
UPDATE departments SET manager_id = 4 WHERE id = 3;
UPDATE departments SET manager_id = 6 WHERE id = 4;
UPDATE departments SET manager_id = 7 WHERE id = 5;

INSERT INTO projects (name, description, department_id, start_date, end_date, budget, status) VALUES
    ('Cloud Migration', 'Migrate services to cloud infrastructure', 1, '2024-01-01', '2024-12-31', 500000.00, 'active'),
    ('Brand Refresh', 'Update brand identity and materials', 2, '2024-03-01', '2024-09-30', 150000.00, 'active'),
    ('ERP System', 'Enterprise resource planning implementation', 3, '2024-02-01', '2025-01-31', 800000.00, 'planning'),
    ('Recruitment Portal', 'Online recruitment management system', 4, '2024-04-01', '2024-10-31', 200000.00, 'active'),
    ('Process Automation', 'Automate key business processes', 5, '2024-01-15', '2024-08-31', 350000.00, 'completed');

INSERT INTO project_assignments (employee_id, project_id, role) VALUES
    (1, 1, 'Developer'), (2, 1, 'Project Lead'), (5, 1, 'Developer'),
    (9, 1, 'DevOps'), (3, 2, 'Lead'), (8, 2, 'Designer'),
    (4, 3, 'Analyst'), (10, 3, 'Reviewer'), (6, 4, 'Lead'),
    (7, 5, 'Lead');

INSERT INTO attendance (employee_id, check_in, check_out, status, record_date) VALUES
    (1, '2024-06-01 09:00:00', '2024-06-01 18:00:00', 'present', '2024-06-01'),
    (2, '2024-06-01 08:30:00', '2024-06-01 19:00:00', 'present', '2024-06-01'),
    (3, '2024-06-01 09:15:00', '2024-06-01 17:30:00', 'present', '2024-06-01'),
    (1, '2024-06-02 09:00:00', '2024-06-02 18:30:00', 'present', '2024-06-02'),
    (4, '2024-06-01 00:00:00', '2024-06-01 00:00:00', 'absent', '2024-06-01'),
    (5, '2024-06-01 09:30:00', '2024-06-01 18:00:00', 'late', '2024-06-01');

INSERT INTO performance_reviews (employee_id, reviewer_id, score, comments, review_period) VALUES
    (1, 2, 4, 'Excellent technical skills, good team player', '2024-H1'),
    (5, 2, 3, 'Good progress, needs more experience', '2024-H1'),
    (3, 7, 5, 'Outstanding marketing campaigns', '2024-H1'),
    (4, 10, 4, 'Accurate and thorough analysis', '2024-H1'),
    (9, 2, 5, 'Critical infrastructure improvements', '2024-H1');

INSERT INTO salary_history (employee_id, old_salary, new_salary, change_reason, effective_date) VALUES
    (1, 20000.00, 25000.00, 'Annual performance raise', '2024-01-01'),
    (2, 30000.00, 35000.00, 'Promotion to Tech Lead', '2023-06-01'),
    (5, 12000.00, 15000.00, 'Probation completed', '2023-03-01');
