package opengauss_web.web

public let HTML_PAGE: String = #"<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OpenGauss Database Console</title>
    <style>
        :root {
            --sidebar-start: #1a1c2e;
            --sidebar-end: #2d3154;
            --header-start: #667eea;
            --header-end: #764ba2;
            --accent: #7c5cff;
            --success: #1f9d67;
            --danger: #e25563;
            --warning: #f59e0b;
            --info: #2563eb;
            --bg: #f5f7fb;
            --card: #ffffff;
            --text: #1f2937;
            --muted: #6b7280;
            --border: #e5e7eb;
            --shadow: 0 20px 45px rgba(15, 23, 42, 0.08);
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            color: var(--text);
            background: linear-gradient(180deg, #eef2ff 0%, #f8fafc 25%, var(--bg) 100%);
        }
        .app {
            display: grid;
            grid-template-columns: 280px 1fr;
            min-height: 100vh;
        }
        .sidebar {
            background: linear-gradient(180deg, var(--sidebar-start), var(--sidebar-end));
            color: #fff;
            padding: 28px 20px;
            position: sticky;
            top: 0;
            height: 100vh;
            box-shadow: 10px 0 30px rgba(15, 23, 42, 0.16);
        }
        .brand {
            padding: 18px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(8px);
            margin-bottom: 24px;
        }
        .brand h1 {
            margin: 0;
            font-size: 24px;
            letter-spacing: 0.4px;
        }
        .brand p {
            margin: 8px 0 0;
            color: rgba(255, 255, 255, 0.72);
            line-height: 1.5;
            font-size: 13px;
        }
        .nav-list { display: flex; flex-direction: column; gap: 10px; }
        .nav-item {
            width: 100%;
            border: 0;
            color: #e5e7eb;
            background: transparent;
            text-align: left;
            padding: 14px 16px;
            border-radius: 16px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.25s ease;
        }
        .nav-item:hover, .nav-item.active {
            background: rgba(255, 255, 255, 0.14);
            color: #fff;
            transform: translateX(4px);
        }
        .sidebar-foot {
            margin-top: 28px;
            padding: 18px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.08);
            font-size: 12px;
            line-height: 1.7;
            color: rgba(255,255,255,0.78);
        }
        .content {
            padding: 28px;
        }
        .hero {
            background: linear-gradient(135deg, var(--header-start), var(--header-end));
            color: white;
            border-radius: 28px;
            padding: 28px 30px;
            box-shadow: var(--shadow);
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 24px;
        }
        .hero h2 {
            margin: 0 0 8px;
            font-size: 30px;
        }
        .hero p {
            margin: 0;
            color: rgba(255,255,255,0.86);
            max-width: 720px;
            line-height: 1.6;
        }
        .hero-badge {
            padding: 14px 18px;
            border-radius: 18px;
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(6px);
            font-weight: 700;
            min-width: 180px;
            text-align: center;
        }
        .section { display: none; animation: fadeIn 0.25s ease; }
        .section.active { display: block; }
        .grid { display: grid; gap: 18px; }
        .stats-grid {
            grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
            margin-bottom: 22px;
        }
        .card {
            background: var(--card);
            border-radius: 22px;
            padding: 22px;
            box-shadow: var(--shadow);
            border: 1px solid rgba(226, 232, 240, 0.9);
        }
        .stat-card {
            position: relative;
            overflow: hidden;
        }
        .stat-card::after {
            content: "";
            position: absolute;
            right: -24px;
            top: -24px;
            width: 100px;
            height: 100px;
            background: radial-gradient(circle, rgba(124, 92, 255, 0.18), transparent 70%);
            border-radius: 50%;
        }
        .stat-title {
            color: var(--muted);
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }
        .stat-value {
            font-size: 34px;
            font-weight: 800;
            margin: 10px 0 6px;
        }
        .stat-sub {
            color: var(--muted);
            font-size: 13px;
        }
        .toolbar {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
        }
        .toolbar-left, .toolbar-right { display: flex; gap: 12px; flex-wrap: wrap; align-items: center; }
        .btn {
            border: 0;
            border-radius: 14px;
            padding: 11px 16px;
            cursor: pointer;
            font-weight: 700;
            transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
        }
        .btn:hover { transform: translateY(-1px); box-shadow: 0 12px 24px rgba(99, 102, 241, 0.16); }
        .btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); color: white; }
        .btn-secondary { background: #eef2ff; color: #4338ca; }
        .btn-danger { background: #fee2e2; color: #b91c1c; }
        .btn-ghost { background: #f8fafc; color: #334155; }
        .input, .textarea, .select {
            width: 100%;
            border-radius: 14px;
            border: 1px solid var(--border);
            padding: 12px 14px;
            font-size: 14px;
            background: #fff;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .input:focus, .textarea:focus, .select:focus {
            border-color: #7c5cff;
            box-shadow: 0 0 0 4px rgba(124, 92, 255, 0.12);
        }
        .textarea { min-height: 130px; resize: vertical; }
        .table-wrap {
            overflow: auto;
            border-radius: 18px;
            border: 1px solid var(--border);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 760px;
            background: #fff;
        }
        th, td {
            padding: 14px 16px;
            text-align: left;
            border-bottom: 1px solid #edf2f7;
            vertical-align: top;
            font-size: 14px;
        }
        th {
            background: #f8fafc;
            color: #475569;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }
        tbody tr:nth-child(even) { background: #fcfdff; }
        tbody tr:hover { background: #f4f7ff; }
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
        }
        .badge.active, .badge.present, .badge.completed { background: #dcfce7; color: #166534; }
        .badge.planning, .badge.late { background: #fef3c7; color: #92400e; }
        .badge.absent, .badge.inactive { background: #fee2e2; color: #991b1b; }
        .badge.default { background: #e0e7ff; color: #4338ca; }
        .split {
            display: grid;
            gap: 18px;
            grid-template-columns: 1.2fr 0.8fr;
        }
        .tab-strip {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 18px;
        }
        .tab-btn {
            border: 0;
            border-radius: 999px;
            padding: 10px 15px;
            background: #eef2ff;
            color: #4338ca;
            font-weight: 700;
            cursor: pointer;
        }
        .tab-btn.active { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }
        .sub-panel { display: none; }
        .sub-panel.active { display: block; }
        .quick-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 18px; }
        .quick-action {
            padding: 18px;
            border-radius: 18px;
            background: linear-gradient(180deg, #ffffff, #f8fbff);
            border: 1px solid var(--border);
        }
        .quick-action h4 { margin: 0 0 8px; }
        .quick-action p { margin: 0 0 14px; color: var(--muted); line-height: 1.5; }
        .muted { color: var(--muted); }
        .modal-mask {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.46);
            display: none;
            align-items: center;
            justify-content: center;
            padding: 18px;
            z-index: 50;
        }
        .modal-mask.show { display: flex; }
        .modal {
            width: min(720px, 100%);
            max-height: 90vh;
            overflow: auto;
            background: white;
            border-radius: 24px;
            box-shadow: 0 30px 80px rgba(15, 23, 42, 0.28);
            padding: 24px;
        }
        .modal h3 { margin: 0 0 8px; font-size: 24px; }
        .modal p { margin: 0 0 20px; color: var(--muted); }
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }
        .form-grid .full { grid-column: 1 / -1; }
        .field label {
            display: block;
            margin-bottom: 8px;
            font-size: 13px;
            font-weight: 700;
            color: #374151;
        }
        .modal-actions {
            margin-top: 20px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        .toast-box {
            position: fixed;
            right: 18px;
            bottom: 18px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            z-index: 60;
        }
        .toast {
            min-width: 260px;
            padding: 14px 16px;
            border-radius: 16px;
            color: white;
            box-shadow: 0 20px 45px rgba(15, 23, 42, 0.16);
            animation: slideUp 0.3s ease;
        }
        .toast.success { background: linear-gradient(135deg, #16a34a, #22c55e); }
        .toast.error { background: linear-gradient(135deg, #dc2626, #ef4444); }
        .toast.info { background: linear-gradient(135deg, #2563eb, #3b82f6); }
        .loading {
            display: none;
            align-items: center;
            gap: 10px;
            color: var(--muted);
            font-weight: 600;
            margin-top: 10px;
        }
        .loading.show { display: inline-flex; }
        .spinner {
            width: 18px;
            height: 18px;
            border-radius: 50%;
            border: 2px solid rgba(124, 92, 255, 0.2);
            border-top-color: var(--accent);
            animation: spin 0.9s linear infinite;
        }
        .empty {
            padding: 32px 18px;
            text-align: center;
            color: var(--muted);
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes slideUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        @media (max-width: 1080px) {
            .app { grid-template-columns: 1fr; }
            .sidebar { position: relative; height: auto; }
            .split { grid-template-columns: 1fr; }
        }
        @media (max-width: 720px) {
            .content { padding: 16px; }
            .hero { padding: 22px; flex-direction: column; align-items: flex-start; }
            .form-grid { grid-template-columns: 1fr; }
            .toolbar { align-items: stretch; }
        }
    </style>
</head>
<body>
    <div class="app">
        <aside class="sidebar">
            <div class="brand">
                <h1>OpenGauss Console</h1>
                <p>仓颉 + stdx HTTP + OpenGauss 驱动。一个现代化的数据库演示控制台，展示 CRUD、统计分析、日志与 SQL 查询能力。</p>
            </div>
            <div class="nav-list">
                <button class="nav-item active" data-section="dashboard">总览仪表盘</button>
                <button class="nav-item" data-section="employees">员工管理</button>
                <button class="nav-item" data-section="departments">部门管理</button>
                <button class="nav-item" data-section="projects">项目管理</button>
                <button class="nav-item" data-section="analytics">高级分析</button>
                <button class="nav-item" data-section="attendance">考勤与绩效</button>
                <button class="nav-item" data-section="sql">SQL 控制台</button>
                <button class="nav-item" data-section="logs">操作日志</button>
            </div>
            <div class="sidebar-foot">
                <div>数据库端口：15432</div>
                <div>应用端口：8080</div>
                <div>示例数据：部门、员工、项目、考勤、绩效、薪资历史</div>
            </div>
        </aside>

        <main class="content">
            <section class="hero">
                <div>
                    <h2>OpenGauss 可视化管理控制台</h2>
                    <p>通过一个漂亮的单页应用，实时调用后端 API，演示员工、部门、项目的增删改查，以及窗口函数、聚合统计、日志审计与只读 SQL 查询。</p>
                </div>
                <div class="hero-badge">
                    <div>实时接口驱动</div>
                    <div id="heroStatus">等待数据加载</div>
                </div>
            </section>

            <section id="dashboard" class="section active">
                <div class="grid stats-grid" id="dashboardStats"></div>
                <div class="split">
                    <div class="card">
                        <div class="toolbar">
                            <div>
                                <h3>快速操作</h3>
                                <div class="muted">通过卡片入口直接进行常用管理操作。</div>
                            </div>
                        </div>
                        <div class="quick-grid">
                            <div class="quick-action">
                                <h4>新增员工</h4>
                                <p>新增员工档案并写入操作日志，自动展示在列表中。</p>
                                <button class="btn btn-primary" onclick="openEmployeeModal()">立即创建</button>
                            </div>
                            <div class="quick-action">
                                <h4>创建部门</h4>
                                <p>快速维护组织结构，支持联动员工与项目数据。</p>
                                <button class="btn btn-secondary" onclick="openDepartmentModal()">添加部门</button>
                            </div>
                            <div class="quick-action">
                                <h4>登记项目</h4>
                                <p>录入预算与所属部门，观察项目统计变化。</p>
                                <button class="btn btn-secondary" onclick="openProjectModal()">新增项目</button>
                            </div>
                            <div class="quick-action">
                                <h4>运行 SQL</h4>
                                <p>使用只读控制台执行 SELECT 查询，快速查看表数据。</p>
                                <button class="btn btn-secondary" onclick="activateSection('sql')">打开 SQL 控制台</button>
                            </div>
                        </div>
                    </div>
                    <div class="card">
                        <div class="toolbar">
                            <div>
                                <h3>最近操作</h3>
                                <div class="muted">后端自动记录新增、更新、删除动作。</div>
                            </div>
                            <button class="btn btn-ghost" onclick="loadLogs()">刷新</button>
                        </div>
                        <div id="dashboardLogs"></div>
                    </div>
                </div>
            </section>

            <section id="employees" class="section">
                <div class="card">
                    <div class="toolbar">
                        <div class="toolbar-left">
                            <div>
                                <h3>员工管理</h3>
                                <div class="muted">支持列表、搜索、新增、编辑与删除。</div>
                            </div>
                        </div>
                        <div class="toolbar-right">
                            <input id="employeeSearch" class="input" style="min-width:240px" placeholder="搜索姓名 / 邮箱 / 职位">
                            <button class="btn btn-primary" onclick="searchEmployees()">搜索</button>
                            <button class="btn btn-secondary" onclick="openEmployeeModal()">新增员工</button>
                        </div>
                    </div>
                    <div id="employeesTable"></div>
                </div>
            </section>

            <section id="departments" class="section">
                <div class="card">
                    <div class="toolbar">
                        <div>
                            <h3>部门管理</h3>
                            <div class="muted">维护组织架构，查看负责人和创建时间。</div>
                        </div>
                        <div class="toolbar-right">
                            <button class="btn btn-primary" onclick="openDepartmentModal()">新增部门</button>
                            <button class="btn btn-ghost" onclick="loadDepartments()">刷新</button>
                        </div>
                    </div>
                    <div id="departmentsTable"></div>
                </div>
            </section>

            <section id="projects" class="section">
                <div class="card">
                    <div class="toolbar">
                        <div>
                            <h3>项目管理</h3>
                            <div class="muted">展示预算、状态、日期与所属部门。</div>
                        </div>
                        <div class="toolbar-right">
                            <button class="btn btn-primary" onclick="openProjectModal()">新增项目</button>
                            <button class="btn btn-ghost" onclick="loadProjects()">刷新</button>
                        </div>
                    </div>
                    <div id="projectsTable"></div>
                </div>
            </section>

            <section id="analytics" class="section">
                <div class="card">
                    <div class="toolbar">
                        <div>
                            <h3>高级分析</h3>
                            <div class="muted">聚合统计、排名、项目投入等可视分析结果。</div>
                        </div>
                        <button class="btn btn-ghost" onclick="loadAnalytics()">刷新分析</button>
                    </div>
                    <div class="tab-strip">
                        <button class="tab-btn active" data-tab-group="analytics" data-tab="salaryRanking">薪资排行</button>
                        <button class="tab-btn" data-tab-group="analytics" data-tab="departmentStats">部门统计</button>
                        <button class="tab-btn" data-tab-group="analytics" data-tab="projectStats">项目统计</button>
                    </div>
                    <div id="salaryRanking" class="sub-panel active"></div>
                    <div id="departmentStats" class="sub-panel"></div>
                    <div id="projectStats" class="sub-panel"></div>
                </div>
            </section>

            <section id="attendance" class="section">
                <div class="card">
                    <div class="toolbar">
                        <div>
                            <h3>考勤与绩效</h3>
                            <div class="muted">查看考勤记录、绩效评价与薪资变更历史。</div>
                        </div>
                        <button class="btn btn-ghost" onclick="loadAttendanceAndReviews()">刷新数据</button>
                    </div>
                    <div class="tab-strip">
                        <button class="tab-btn active" data-tab-group="people" data-tab="attendancePanel">考勤</button>
                        <button class="tab-btn" data-tab-group="people" data-tab="reviewPanel">绩效</button>
                        <button class="tab-btn" data-tab-group="people" data-tab="salaryHistoryPanel">薪资历史</button>
                    </div>
                    <div id="attendancePanel" class="sub-panel active"></div>
                    <div id="reviewPanel" class="sub-panel"></div>
                    <div id="salaryHistoryPanel" class="sub-panel"></div>
                </div>
            </section>

            <section id="sql" class="section">
                <div class="card">
                    <div class="toolbar">
                        <div>
                            <h3>SQL 控制台</h3>
                            <div class="muted">仅允许执行 SELECT 查询，结果预览最多展示 100 行，并对每行输出前 10 列。</div>
                        </div>
                    </div>
                    <div class="field">
                        <label for="sqlInput">输入 SQL</label>
                        <textarea id="sqlInput" class="textarea">SELECT e.name, d.name AS department, e.salary FROM employees e LEFT JOIN departments d ON e.department_id = d.id ORDER BY e.salary DESC;</textarea>
                    </div>
                    <div class="toolbar" style="margin-top:16px;">
                        <div class="toolbar-left">
                            <button class="btn btn-primary" onclick="runSql()">执行查询</button>
                            <button class="btn btn-ghost" onclick="document.getElementById('sqlInput').value='SELECT * FROM departments ORDER BY id';">部门示例</button>
                            <button class="btn btn-ghost" onclick="document.getElementById('sqlInput').value='SELECT * FROM projects ORDER BY id';">项目示例</button>
                        </div>
                        <div id="sqlLoading" class="loading"><span class="spinner"></span>执行中...</div>
                    </div>
                    <div id="sqlResult"></div>
                </div>
            </section>

            <section id="logs" class="section">
                <div class="card">
                    <div class="toolbar">
                        <div>
                            <h3>操作日志</h3>
                            <div class="muted">审计最近 20 条由业务接口触发的数据库操作。</div>
                        </div>
                        <button class="btn btn-ghost" onclick="loadLogs()">刷新日志</button>
                    </div>
                    <div id="logsTable"></div>
                </div>
            </section>
        </main>
    </div>

    <div id="modalMask" class="modal-mask">
        <div class="modal">
            <h3 id="modalTitle">操作</h3>
            <p id="modalDesc">填写表单并提交。</p>
            <form id="modalForm">
                <input type="hidden" id="formType">
                <input type="hidden" id="employeeId">
                <div id="departmentFields" class="form-grid" style="display:none;">
                    <div class="field full">
                        <label>部门名称</label>
                        <input id="departmentName" class="input" placeholder="例如：Platform Engineering">
                    </div>
                    <div class="field full">
                        <label>部门描述</label>
                        <textarea id="departmentDescription" class="textarea" placeholder="填写部门职责与定位"></textarea>
                    </div>
                </div>

                <div id="employeeFields" class="form-grid" style="display:none;">
                    <div class="field">
                        <label>姓名</label>
                        <input id="employeeName" class="input" placeholder="姓名">
                    </div>
                    <div class="field">
                        <label>邮箱</label>
                        <input id="employeeEmail" class="input" placeholder="邮箱">
                    </div>
                    <div class="field">
                        <label>电话</label>
                        <input id="employeePhone" class="input" placeholder="电话">
                    </div>
                    <div class="field">
                        <label>部门</label>
                        <select id="employeeDept" class="select"></select>
                    </div>
                    <div class="field">
                        <label>职位</label>
                        <input id="employeePosition" class="input" placeholder="职位">
                    </div>
                    <div class="field">
                        <label>薪资</label>
                        <input id="employeeSalary" class="input" placeholder="薪资">
                    </div>
                </div>

                <div id="projectFields" class="form-grid" style="display:none;">
                    <div class="field full">
                        <label>项目名称</label>
                        <input id="projectName" class="input" placeholder="项目名称">
                    </div>
                    <div class="field full">
                        <label>项目描述</label>
                        <textarea id="projectDescription" class="textarea" placeholder="项目目标、范围、阶段"></textarea>
                    </div>
                    <div class="field">
                        <label>所属部门</label>
                        <select id="projectDept" class="select"></select>
                    </div>
                    <div class="field">
                        <label>预算</label>
                        <input id="projectBudget" class="input" placeholder="预算金额">
                    </div>
                </div>
            </form>
            <div class="modal-actions">
                <button class="btn btn-ghost" onclick="closeModal()" type="button">取消</button>
                <button class="btn btn-primary" onclick="submitModal()" type="button">提交</button>
            </div>
        </div>
    </div>

    <div id="toastBox" class="toast-box"></div>

    <script>
        var state = {
            employees: [],
            departments: [],
            projects: [],
            logs: []
        };

        function activateSection(id) {
            document.querySelectorAll('.section').forEach(function(section) {
                section.classList.toggle('active', section.id === id);
            });
            document.querySelectorAll('.nav-item').forEach(function(btn) {
                btn.classList.toggle('active', btn.getAttribute('data-section') === id);
            });
            if (id === 'employees') { loadEmployees(); }
            if (id === 'departments') { loadDepartments(); }
            if (id === 'projects') { loadProjects(); }
            if (id === 'analytics') { loadAnalytics(); }
            if (id === 'attendance') { loadAttendanceAndReviews(); }
            if (id === 'logs') { loadLogs(); }
        }

        function escapeHtml(value) {
            return String(value == null ? '' : value)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        async function fetchJson(url, options) {
            var response = await fetch(url, options || {});
            if (!response.ok) {
                throw new Error('HTTP ' + response.status);
            }
            return await response.json();
        }

        async function sendForm(url, method, data) {
            return await fetchJson(url, {
                method: method,
                headers: { 'content-type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: new URLSearchParams(data).toString()
            });
        }

        function showToast(message, type) {
            var toast = document.createElement('div');
            toast.className = 'toast ' + (type || 'info');
            toast.textContent = message;
            document.getElementById('toastBox').appendChild(toast);
            setTimeout(function() {
                toast.remove();
            }, 2800);
        }

        function showError(error) {
            showToast(error.message || '请求失败', 'error');
        }

        function badge(value) {
            var status = String(value || '').toLowerCase();
            var cls = 'default';
            if (status === 'active' || status === 'present' || status === 'completed') { cls = status; }
            if (status === 'planning' || status === 'late') { cls = status; }
            if (status === 'absent' || status === 'inactive') { cls = status; }
            return '<span class="badge ' + cls + '">' + escapeHtml(value || 'N/A') + '</span>';
        }

        function renderTable(containerId, columns, rows, actionBuilder) {
            var container = document.getElementById(containerId);
            if (!rows || !rows.length) {
                container.innerHTML = '<div class="empty">暂无数据</div>';
                return;
            }
            var html = '<div class="table-wrap"><table><thead><tr>';
            columns.forEach(function(col) {
                html += '<th>' + escapeHtml(col.label) + '</th>';
            });
            if (actionBuilder) {
                html += '<th>操作</th>';
            }
            html += '</tr></thead><tbody>';
            rows.forEach(function(row) {
                html += '<tr>';
                columns.forEach(function(col) {
                    var value = row[col.key];
                    if (col.render) {
                        html += '<td>' + col.render(value, row) + '</td>';
                    } else {
                        html += '<td>' + escapeHtml(value || '') + '</td>';
                    }
                });
                if (actionBuilder) {
                    html += '<td>' + actionBuilder(row) + '</td>';
                }
                html += '</tr>';
            });
            html += '</tbody></table></div>';
            container.innerHTML = html;
        }

        function renderDashboard() {
            var employeeCount = state.employees.length;
            var departmentCount = state.departments.length;
            var projectCount = state.projects.length;
            var activeProjects = state.projects.filter(function(item) { return item.status === 'active'; }).length;
            var totalSalary = state.employees.reduce(function(sum, item) {
                return sum + Number(item.salary || 0);
            }, 0);
            var cards = [
                { title: '员工总数', value: employeeCount, sub: '活跃业务演示数据' },
                { title: '部门数量', value: departmentCount, sub: '组织结构已装载' },
                { title: '项目数量', value: projectCount, sub: '项目池已初始化' },
                { title: '活跃项目', value: activeProjects, sub: '正在推进中的项目' },
                { title: '薪资总额', value: '¥' + totalSalary.toLocaleString(), sub: '基于当前员工列表统计' }
            ];
            var html = '';
            cards.forEach(function(card) {
                html += '<div class="card stat-card"><div class="stat-title">' + escapeHtml(card.title) + '</div><div class="stat-value">' + escapeHtml(card.value) + '</div><div class="stat-sub">' + escapeHtml(card.sub) + '</div></div>';
            });
            document.getElementById('dashboardStats').innerHTML = html;
            document.getElementById('heroStatus').textContent = '已加载 ' + employeeCount + ' 名员工 / ' + projectCount + ' 个项目';
        }

        function renderDashboardLogs() {
            var logs = state.logs.slice(0, 6);
            if (!logs.length) {
                document.getElementById('dashboardLogs').innerHTML = '<div class="empty">暂无日志</div>';
                return;
            }
            var html = '<div class="grid">';
            logs.forEach(function(log) {
                html += '<div class="quick-action">'
                    + '<div style="display:flex;justify-content:space-between;gap:12px;align-items:flex-start;">'
                    + '<strong>' + escapeHtml(log.table_name || '-') + '</strong>'
                    + badge(log.operation || '')
                    + '</div>'
                    + '<p style="margin-top:10px;">' + escapeHtml(log.details || '-') + '</p>'
                    + '<div class="muted">' + escapeHtml(log.operated_at || '') + '</div>'
                    + '</div>';
            });
            html += '</div>';
            document.getElementById('dashboardLogs').innerHTML = html;
        }

        async function loadDashboard() {
            try {
                var results = await Promise.all([
                    fetchJson('/api/employees'),
                    fetchJson('/api/departments'),
                    fetchJson('/api/projects'),
                    fetchJson('/api/logs')
                ]);
                state.employees = results[0];
                state.departments = results[1];
                state.projects = results[2];
                state.logs = results[3];
                renderDashboard();
                renderDashboardLogs();
                fillDepartmentSelects();
            } catch (error) {
                showError(error);
            }
        }

        async function loadDepartments() {
            try {
                state.departments = await fetchJson('/api/departments');
                fillDepartmentSelects();
                renderTable('departmentsTable', [
                    { key: 'id', label: 'ID' },
                    { key: 'name', label: '名称' },
                    { key: 'description', label: '描述' },
                    { key: 'manager_name', label: '负责人' },
                    { key: 'created_at', label: '创建时间' }
                ], state.departments, function(row) {
                    return '<button class="btn btn-danger" onclick="deleteDepartment(' + Number(row.id) + ')">删除</button>';
                });
                renderDashboard();
            } catch (error) {
                showError(error);
            }
        }

        async function loadEmployees(keyword) {
            try {
                var url = '/api/employees';
                if (keyword) {
                    url += '?search=' + encodeURIComponent(keyword);
                }
                state.employees = await fetchJson(url);
                renderTable('employeesTable', [
                    { key: 'id', label: 'ID' },
                    { key: 'name', label: '姓名' },
                    { key: 'email', label: '邮箱' },
                    { key: 'phone', label: '电话' },
                    { key: 'department', label: '部门' },
                    { key: 'position', label: '职位' },
                    { key: 'salary', label: '薪资' },
                    { key: 'hire_date', label: '入职日期' },
                    { key: 'status', label: '状态', render: function(value) { return badge(value); } }
                ], state.employees, function(row) {
                    return '<div style="display:flex;gap:8px;flex-wrap:wrap;">'
                        + '<button class="btn btn-secondary" onclick="openEmployeeModal(' + Number(row.id) + ')">编辑</button>'
                        + '<button class="btn btn-danger" onclick="deleteEmployee(' + Number(row.id) + ')">删除</button>'
                        + '</div>';
                });
                renderDashboard();
            } catch (error) {
                showError(error);
            }
        }

        async function loadProjects() {
            try {
                state.projects = await fetchJson('/api/projects');
                renderTable('projectsTable', [
                    { key: 'id', label: 'ID' },
                    { key: 'name', label: '项目名称' },
                    { key: 'description', label: '描述' },
                    { key: 'department', label: '部门' },
                    { key: 'start_date', label: '开始日期' },
                    { key: 'end_date', label: '结束日期' },
                    { key: 'budget', label: '预算' },
                    { key: 'status', label: '状态', render: function(value) { return badge(value); } }
                ], state.projects, function(row) {
                    return '<button class="btn btn-danger" onclick="deleteProject(' + Number(row.id) + ')">删除</button>';
                });
                renderDashboard();
            } catch (error) {
                showError(error);
            }
        }

        async function loadAnalytics() {
            try {
                var results = await Promise.all([
                    fetchJson('/api/stats/salary-ranking'),
                    fetchJson('/api/stats/departments'),
                    fetchJson('/api/stats/projects')
                ]);
                renderTable('salaryRanking', [
                    { key: 'rank', label: '排名' },
                    { key: 'name', label: '姓名' },
                    { key: 'position', label: '职位' },
                    { key: 'department', label: '部门' },
                    { key: 'salary', label: '薪资' }
                ], results[0]);
                renderTable('departmentStats', [
                    { key: 'department', label: '部门' },
                    { key: 'employee_count', label: '员工数' },
                    { key: 'avg_salary', label: '平均薪资' },
                    { key: 'total_salary', label: '薪资总额' }
                ], results[1]);
                renderTable('projectStats', [
                    { key: 'project', label: '项目' },
                    { key: 'status', label: '状态', render: function(value) { return badge(value); } },
                    { key: 'budget', label: '预算' },
                    { key: 'members', label: '成员数' }
                ], results[2]);
            } catch (error) {
                showError(error);
            }
        }

        async function loadAttendanceAndReviews() {
            try {
                var results = await Promise.all([
                    fetchJson('/api/attendance'),
                    fetchJson('/api/reviews'),
                    fetchJson('/api/salary-history')
                ]);
                renderTable('attendancePanel', [
                    { key: 'id', label: 'ID' },
                    { key: 'employee', label: '员工' },
                    { key: 'check_in', label: '签到' },
                    { key: 'check_out', label: '签退' },
                    { key: 'status', label: '状态', render: function(value) { return badge(value); } },
                    { key: 'record_date', label: '日期' }
                ], results[0]);
                renderTable('reviewPanel', [
                    { key: 'id', label: 'ID' },
                    { key: 'employee', label: '员工' },
                    { key: 'reviewer', label: '评审人' },
                    { key: 'score', label: '评分' },
                    { key: 'comments', label: '评语' },
                    { key: 'period', label: '周期' }
                ], results[1]);
                renderTable('salaryHistoryPanel', [
                    { key: 'id', label: 'ID' },
                    { key: 'employee', label: '员工' },
                    { key: 'old_salary', label: '原薪资' },
                    { key: 'new_salary', label: '新薪资' },
                    { key: 'reason', label: '原因' },
                    { key: 'effective_date', label: '生效日期' }
                ], results[2]);
            } catch (error) {
                showError(error);
            }
        }

        async function loadLogs() {
            try {
                state.logs = await fetchJson('/api/logs');
                renderTable('logsTable', [
                    { key: 'id', label: 'ID' },
                    { key: 'table_name', label: '表名' },
                    { key: 'operation', label: '操作', render: function(value) { return badge(value); } },
                    { key: 'record_id', label: '记录 ID' },
                    { key: 'details', label: '详情' },
                    { key: 'operated_at', label: '操作时间' }
                ], state.logs);
                renderDashboardLogs();
            } catch (error) {
                showError(error);
            }
        }

        function fillDepartmentSelects() {
            var options = state.departments.map(function(dep) {
                return '<option value="' + escapeHtml(dep.id) + '">' + escapeHtml(dep.name) + '</option>';
            }).join('');
            document.getElementById('employeeDept').innerHTML = options;
            document.getElementById('projectDept').innerHTML = options;
        }

        function openDepartmentModal() {
            resetModal();
            document.getElementById('formType').value = 'department';
            document.getElementById('modalTitle').textContent = '新增部门';
            document.getElementById('modalDesc').textContent = '创建新的部门记录。';
            document.getElementById('departmentFields').style.display = 'grid';
            document.getElementById('modalMask').classList.add('show');
        }

        function openEmployeeModal(id) {
            resetModal();
            document.getElementById('formType').value = id ? 'employee-edit' : 'employee';
            document.getElementById('modalTitle').textContent = id ? '编辑员工' : '新增员工';
            document.getElementById('modalDesc').textContent = id ? '修改员工基础信息与归属部门。' : '新增一位员工并写入操作日志。';
            document.getElementById('employeeFields').style.display = 'grid';
            fillDepartmentSelects();
            if (id) {
                var target = state.employees.find(function(item) { return Number(item.id) === Number(id); });
                if (target) {
                    document.getElementById('employeeId').value = target.id || '';
                    document.getElementById('employeeName').value = target.name || '';
                    document.getElementById('employeeEmail').value = target.email || '';
                    document.getElementById('employeePhone').value = target.phone || '';
                    document.getElementById('employeeDept').value = target.department_id || '';
                    document.getElementById('employeePosition').value = target.position || '';
                    document.getElementById('employeeSalary').value = target.salary || '';
                }
            }
            document.getElementById('modalMask').classList.add('show');
        }

        function openProjectModal() {
            resetModal();
            document.getElementById('formType').value = 'project';
            document.getElementById('modalTitle').textContent = '新增项目';
            document.getElementById('modalDesc').textContent = '创建项目并设置预算与所属部门。';
            document.getElementById('projectFields').style.display = 'grid';
            fillDepartmentSelects();
            document.getElementById('modalMask').classList.add('show');
        }

        function closeModal() {
            document.getElementById('modalMask').classList.remove('show');
        }

        function resetModal() {
            document.getElementById('modalForm').reset();
            document.getElementById('employeeId').value = '';
            document.getElementById('departmentFields').style.display = 'none';
            document.getElementById('employeeFields').style.display = 'none';
            document.getElementById('projectFields').style.display = 'none';
        }

        async function submitModal() {
            var type = document.getElementById('formType').value;
            try {
                var result;
                if (type === 'department') {
                    result = await sendForm('/api/departments', 'POST', {
                        name: document.getElementById('departmentName').value,
                        description: document.getElementById('departmentDescription').value
                    });
                    handleMutationResult(result, loadDepartments);
                }
                if (type === 'employee') {
                    result = await sendForm('/api/employees', 'POST', {
                        name: document.getElementById('employeeName').value,
                        email: document.getElementById('employeeEmail').value,
                        phone: document.getElementById('employeePhone').value,
                        department_id: document.getElementById('employeeDept').value,
                        position: document.getElementById('employeePosition').value,
                        salary: document.getElementById('employeeSalary').value
                    });
                    handleMutationResult(result, loadEmployees);
                }
                if (type === 'employee-edit') {
                    result = await sendForm('/api/employees', 'PUT', {
                        id: document.getElementById('employeeId').value,
                        name: document.getElementById('employeeName').value,
                        email: document.getElementById('employeeEmail').value,
                        phone: document.getElementById('employeePhone').value,
                        department_id: document.getElementById('employeeDept').value,
                        position: document.getElementById('employeePosition').value,
                        salary: document.getElementById('employeeSalary').value
                    });
                    handleMutationResult(result, loadEmployees);
                }
                if (type === 'project') {
                    result = await sendForm('/api/projects', 'POST', {
                        name: document.getElementById('projectName').value,
                        description: document.getElementById('projectDescription').value,
                        department_id: document.getElementById('projectDept').value,
                        budget: document.getElementById('projectBudget').value
                    });
                    handleMutationResult(result, loadProjects);
                }
            } catch (error) {
                showError(error);
            }
        }

        function handleMutationResult(result, reloadFn) {
            if (result && result.success) {
                showToast(result.message || '操作成功', 'success');
                closeModal();
                Promise.resolve(reloadFn()).then(loadDashboard).then(loadLogs);
            } else {
                showToast((result && result.message) || '操作失败', 'error');
            }
        }

        async function deleteDepartment(id) {
            if (!confirm('确定删除该部门吗？')) { return; }
            try {
                var result = await fetchJson('/api/departments?id=' + encodeURIComponent(id), { method: 'DELETE' });
                handleMutationResult(result, loadDepartments);
            } catch (error) {
                showError(error);
            }
        }

        async function deleteEmployee(id) {
            if (!confirm('确定删除该员工吗？')) { return; }
            try {
                var result = await fetchJson('/api/employees?id=' + encodeURIComponent(id), { method: 'DELETE' });
                handleMutationResult(result, loadEmployees);
            } catch (error) {
                showError(error);
            }
        }

        async function deleteProject(id) {
            if (!confirm('确定删除该项目吗？')) { return; }
            try {
                var result = await fetchJson('/api/projects?id=' + encodeURIComponent(id), { method: 'DELETE' });
                handleMutationResult(result, loadProjects);
            } catch (error) {
                showError(error);
            }
        }

        async function runSql() {
            var loading = document.getElementById('sqlLoading');
            loading.classList.add('show');
            try {
                var result = await sendForm('/api/sql', 'POST', {
                    sql: document.getElementById('sqlInput').value
                });
                if (result.error) {
                    document.getElementById('sqlResult').innerHTML = '<div class="empty">' + escapeHtml(result.error) + '</div>';
                    showToast(result.error, 'error');
                } else {
                    renderTable('sqlResult', [
                        { key: 'row', label: '查询结果' }
                    ], result);
                    showToast('SQL 执行完成', 'success');
                }
            } catch (error) {
                showError(error);
            } finally {
                loading.classList.remove('show');
            }
        }

        function searchEmployees() {
            var keyword = document.getElementById('employeeSearch').value.trim();
            loadEmployees(keyword);
        }

        function setupTabs() {
            document.querySelectorAll('.tab-btn').forEach(function(btn) {
                btn.addEventListener('click', function() {
                    var group = btn.getAttribute('data-tab-group');
                    var tab = btn.getAttribute('data-tab');
                    document.querySelectorAll('.tab-btn[data-tab-group="' + group + '"]').forEach(function(item) {
                        item.classList.remove('active');
                    });
                    btn.classList.add('active');
                    if (group === 'analytics') {
                        ['salaryRanking', 'departmentStats', 'projectStats'].forEach(function(id) {
                            document.getElementById(id).classList.toggle('active', id === tab);
                        });
                    }
                    if (group === 'people') {
                        ['attendancePanel', 'reviewPanel', 'salaryHistoryPanel'].forEach(function(id) {
                            document.getElementById(id).classList.toggle('active', id === tab);
                        });
                    }
                });
            });
        }

        function setupNavigation() {
            document.querySelectorAll('.nav-item').forEach(function(btn) {
                btn.addEventListener('click', function() {
                    activateSection(btn.getAttribute('data-section'));
                });
            });
            document.getElementById('employeeSearch').addEventListener('keydown', function(event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    searchEmployees();
                }
            });
            document.getElementById('modalMask').addEventListener('click', function(event) {
                if (event.target.id === 'modalMask') {
                    closeModal();
                }
            });
        }

        async function init() {
            setupNavigation();
            setupTabs();
            await loadDashboard();
            await loadEmployees();
            await loadDepartments();
            await loadProjects();
            await loadAnalytics();
            await loadAttendanceAndReviews();
            await loadLogs();
            showToast('控制台已就绪', 'info');
        }

        window.addEventListener('DOMContentLoaded', init);
    </script>
</body>
</html>"#
