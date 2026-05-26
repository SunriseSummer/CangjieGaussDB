# OpenGauss Web Console

基于仓颉语言（Cangjie）实现的 OpenGauss 数据库 Web 管理控制台。通过精美的网页界面，交互式展示对 OpenGauss 数据库的各种基础操作和高级操作。

## 项目特性

### 基础数据操作
- **员工管理**：增删改查员工信息，支持关键字搜索
- **部门管理**：创建、查看、删除部门
- **项目管理**：项目的全生命周期管理，状态更新

### 高级数据操作
- **部门统计分析**：使用聚合函数（COUNT、AVG、SUM）统计各部门数据
- **项目统计**：展示项目预算、团队规模等信息
- **薪资排行榜**：使用窗口函数（RANK OVER）实现员工薪资排名
- **绩效评审**：多表关联查询展示绩效评分
- **薪资变更历史**：记录员工薪资调整轨迹
- **考勤记录**：展示员工出勤状况

### 数据库高级功能
- **视图管理**：创建和查询数据库视图（CREATE VIEW）
- **索引管理**：创建和列出数据库索引（CREATE INDEX）
- **批量操作**：事务内批量插入员工数据
- **事务演示**：员工间薪资转移（事务 BEGIN/COMMIT/ROLLBACK）
- **聚合函数**：MIN、MAX、AVG、SUM、COUNT、STDDEV 综合演示
- **子查询**：查询高于平均薪资的员工

### 其他功能
- **SQL 控制台**：直接执行 SELECT 查询（安全限制仅允许查询操作）
- **数据导出**：导出员工数据和部门统计为 CSV 文件
- **操作日志**：自动记录所有数据变更操作

### 技术架构
- **后端**：仓颉语言，基于 `stdx.net.http` 实现 HTTP 服务器
- **数据库驱动**：使用 `cangjie_tpc::opengauss` 驱动连接 OpenGauss
- **前端**：独立 HTML 文件，运行时从文件加载，纯 HTML/CSS/JavaScript 单页应用
- **数据库**：OpenGauss 3.0.0，通过 Docker 部署

### 数据库表结构（8 张表）

| 表名 | 说明 |
|------|------|
| `departments` | 部门信息 |
| `employees` | 员工信息 |
| `projects` | 项目信息 |
| `project_assignments` | 项目人员分配 |
| `attendance` | 考勤记录 |
| `performance_reviews` | 绩效评审 |
| `salary_history` | 薪资变更历史 |
| `operation_logs` | 操作日志 |

## 环境要求

- Docker & Docker Compose
- 仓颉 SDK 1.1.0
- 仓颉 STDX 1.1.0

## 安装运行

### 1. 安装仓颉 SDK 和 STDX

```bash
# 下载并解压 SDK
wget https://github.com/SunriseSummer/CangjieSDK/releases/download/1.1.0/cangjie-sdk-linux-x64-1.1.0.tar.gz
tar xzf cangjie-sdk-linux-x64-1.1.0.tar.gz
source cangjie/envsetup.sh

# 下载并解压 STDX
wget https://github.com/SunriseSummer/CangjieSDK/releases/download/1.1.0/cangjie-stdx-linux-x64-1.1.0.1.zip
unzip cangjie-stdx-linux-x64-1.1.0.1.zip

# 设置环境变量
export CANGJIE_STDX_PATH=$(pwd)/linux_x86_64_cjnative/dynamic/stdx
export LD_LIBRARY_PATH=$CANGJIE_STDX_PATH:$LD_LIBRARY_PATH
```

### 2. 启动数据库

```bash
cd opengauss-web
docker compose up -d
```

等待约 15-30 秒，数据库会自动初始化并导入示例数据。可通过以下命令检查状态：

```bash
docker logs opengauss-web-db
```

### 3. 编译项目

```bash
cd opengauss-web
cjpm build
```

### 4. 运行 Web 服务器

```bash
# 设置运行时库路径
export LD_LIBRARY_PATH=$CANGJIE_STDX_PATH:$(pwd)/target/release/opengauss@cangjie_tpc:$LD_LIBRARY_PATH

# 启动服务器
./target/release/bin/main
```

服务器默认监听 `http://127.0.0.1:8080`。

### 5. 访问页面

打开浏览器访问 `http://127.0.0.1:8080`，即可看到 Web 管理控制台。

## 环境变量配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `OPENGAUSS_WEB_DB_URL` | `opengauss://gaussdb:Root%40123456@127.0.0.1:15432/omm?sslmode=disable` | 数据库连接 URL |
| `OPENGAUSS_WEB_HOST` | `127.0.0.1` | 服务器绑定地址 |
| `OPENGAUSS_WEB_PORT` | `8080` | 服务器端口 |

## API 接口

### 基础 CRUD

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/departments` | 获取部门列表 |
| POST | `/api/departments` | 添加部门 |
| DELETE | `/api/departments?id=` | 删除部门 |
| GET | `/api/employees` | 获取员工列表 |
| GET | `/api/employees?search=` | 搜索员工 |
| POST | `/api/employees` | 添加员工 |
| PUT | `/api/employees` | 更新员工 |
| DELETE | `/api/employees?id=` | 删除员工 |
| GET | `/api/projects` | 获取项目列表 |
| POST | `/api/projects` | 添加项目 |
| PUT | `/api/projects` | 更新项目状态 |
| DELETE | `/api/projects?id=` | 删除项目 |

### 统计分析

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/stats/departments` | 部门统计（COUNT / AVG / SUM） |
| GET | `/api/stats/projects` | 项目统计 |
| GET | `/api/stats/salary-ranking` | 薪资排行榜（RANK 窗口函数） |

### 记录查询

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/reviews` | 绩效评审（多表 JOIN） |
| GET | `/api/salary-history` | 薪资变更历史 |
| GET | `/api/attendance` | 考勤记录 |
| GET | `/api/logs` | 操作日志 |

### 数据库高级功能

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/advanced/views` | 列出视图 |
| POST | `/api/advanced/views` | 创建视图 |
| GET | `/api/advanced/indexes` | 列出索引 |
| POST | `/api/advanced/indexes` | 创建索引 |
| POST | `/api/advanced/batch-insert` | 批量插入员工 |
| POST | `/api/advanced/transfer` | 薪资转移（事务） |
| GET | `/api/advanced/aggregates` | 聚合函数演示 |
| GET | `/api/advanced/subquery` | 子查询演示 |

### 其他

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/sql` | SQL 控制台（仅 SELECT） |
| GET | `/api/export/employees` | 导出员工 CSV |
| GET | `/api/export/dept-stats` | 导出部门统计 CSV |

## 项目结构

```
opengauss-web/
├── cjpm.toml                  # 仓颉项目配置
├── docker-compose.yml         # OpenGauss Docker 配置
├── readme.md                  # 项目文档
├── static/
│   └── index.html             # 前端页面（运行时加载）
├── sql/
│   └── init.sql               # 数据库初始化脚本
└── src/
    ├── main.cj                # 主入口，组装服务与路由
    ├── dao/
    │   ├── DbConnector.cj     # 数据库连接、查询、事务
    │   └── JsonHelper.cj      # JSON 转义与响应构造
    ├── service/
    │   ├── DeptService.cj     # 部门业务
    │   ├── EmpService.cj      # 员工业务
    │   ├── ProjectService.cj  # 项目业务
    │   ├── StatsService.cj    # 统计分析
    │   ├── RecordService.cj   # 考勤 / 绩效 / 薪资 / 日志
    │   ├── AdvancedService.cj # 视图 / 索引 / 批量 / 事务
    │   ├── SqlService.cj      # SQL 控制台
    │   └── ExportService.cj   # 数据导出
    ├── route/
    │   ├── DeptRoute.cj       # 部门路由
    │   ├── EmpRoute.cj        # 员工路由
    │   ├── ProjectRoute.cj    # 项目路由
    │   ├── StatsRoute.cj      # 统计路由
    │   ├── RecordRoute.cj     # 记录路由
    │   ├── AdvancedRoute.cj   # 高级功能路由
    │   ├── SqlRoute.cj        # SQL 控制台路由
    │   └── ExportRoute.cj     # 导出路由
    ├── util/
    │   ├── HttpHelper.cj      # HTTP 工具函数
    │   └── SqlValidator.cj    # SQL 安全校验
    └── web/
        └── PageLoader.cj      # 从文件加载 HTML 页面
```

## 使用指导

### 员工管理

1. 在左侧导航栏点击「员工管理」
2. 点击「添加员工」按钮添加新员工
3. 在搜索框输入关键字可按姓名、邮箱、职位搜索
4. 点击每行的编辑或删除按钮进行操作
5. 所有操作会自动记录到操作日志中

### 部门与项目管理

1. 在导航栏切换到相应页面
2. 使用添加按钮创建新记录
3. 项目支持状态更新（planning → active → completed）

### 数据库高级功能

1. **视图管理**：输入视图名称和 SELECT 查询，创建数据库视图
2. **索引管理**：选择表和列，创建数据库索引以优化查询性能
3. **批量插入**：指定数量和前缀，事务内批量插入员工
4. **事务演示**：在两个员工间转移薪资，演示事务 ACID 特性
5. **聚合函数**：展示 COUNT、MIN、MAX、AVG、SUM、STDDEV 结果
6. **子查询**：展示高于平均薪资的员工列表

### 数据分析

1. 点击「高级分析」查看部门统计和项目统计
2. 查看薪资排行榜（基于 RANK 窗口函数）
3. 查看考勤记录和绩效评审

### SQL 控制台

1. 点击「SQL 控制台」进入交互式查询界面
2. 输入 SELECT 查询语句或选择预设示例
3. 点击执行，查看结果（最多 100 行 × 10 列）
4. 仅允许 SELECT 查询，其他操作会被安全拒绝

### 数据导出

1. 点击「数据导出」页面
2. 选择导出员工列表或部门统计
3. 自动下载 CSV 文件
