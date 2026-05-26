# OpenGauss Web Console

基于仓颉语言（Cangjie）实现的 OpenGauss 数据库 Web 管理控制台。通过精美的网页界面，交互式展示对 OpenGauss 数据库的各种基础操作和高级操作。

## 项目特性

### 基础数据操作
- **员工管理**：增删改查员工信息，支持关键字搜索
- **部门管理**：创建、查看、删除部门
- **项目管理**：项目的全生命周期管理

### 高级数据操作
- **部门统计分析**：统计各部门员工数量、平均薪资、总薪资
- **项目统计**：展示项目预算、团队规模等信息
- **薪资排行榜**：使用窗口函数（RANK）实现员工薪资排名
- **绩效评审**：多表关联查询展示绩效评分
- **薪资变更历史**：记录员工薪资调整轨迹
- **考勤记录**：展示员工出勤状况
- **SQL 控制台**：直接执行 SELECT 查询（安全限制仅允许查询操作）
- **操作日志**：自动记录所有数据变更操作

### 技术架构
- **后端**：仓颉语言，基于 `stdx.net.http` 实现 HTTP 服务器
- **数据库驱动**：使用 `cangjie_tpc::opengauss` 驱动连接 OpenGauss
- **前端**：单页应用（SPA），纯 HTML/CSS/JavaScript，无第三方依赖
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
- OpenSSL 3

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

### 基础 CRUD 接口

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
| DELETE | `/api/projects?id=` | 删除项目 |

### 高级查询接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/stats/departments` | 部门统计（聚合查询） |
| GET | `/api/stats/projects` | 项目统计 |
| GET | `/api/stats/salary-ranking` | 薪资排行榜（窗口函数） |
| GET | `/api/reviews` | 绩效评审（多表关联） |
| GET | `/api/salary-history` | 薪资变更历史 |
| GET | `/api/attendance` | 考勤记录 |
| GET | `/api/logs` | 操作日志 |
| POST | `/api/sql` | SQL 控制台（仅 SELECT） |

## 项目结构

```
opengauss-web/
├── cjpm.toml              # 仓颉项目配置
├── docker-compose.yml     # OpenGauss 数据库 Docker 配置
├── readme.md              # 项目文档
├── sql/
│   └── init.sql           # 数据库初始化脚本（建表+示例数据）
└── src/
    ├── main.cj            # 主入口，HTTP 路由注册
    ├── dao/
    │   └── DbConnector.cj # 数据库连接与查询封装
    ├── service/
    │   └── DataService.cj # 业务逻辑层
    └── web/
        └── HtmlPage.cj    # 前端 HTML 页面
```

## 使用指导

### 员工管理

1. 在左侧导航栏点击「Employees」
2. 点击「Add Employee」按钮添加新员工
3. 在搜索框输入关键字可按姓名、邮箱、职位搜索
4. 点击每行的「Edit」或「Delete」按钮进行编辑或删除
5. 所有操作会自动记录到操作日志中

### 部门与项目管理

1. 在导航栏切换到相应页面
2. 使用「Add」按钮创建新记录
3. 使用「Delete」按钮删除记录

### 数据分析

1. 点击「Statistics」查看部门统计和项目统计
2. 点击「Salary Ranking」查看薪资排行榜
3. 点击「Reviews」和「Attendance」查看详细记录

### SQL 控制台

1. 点击「SQL Console」进入 SQL 控制台
2. 输入 SELECT 查询语句
3. 点击「Execute」执行查询
4. 仅允许 SELECT 查询，其他操作会被拒绝
5. 示例查询：
   - `SELECT * FROM employees WHERE salary > 20000`
   - `SELECT d.name, COUNT(e.id) FROM departments d LEFT JOIN employees e ON d.id = e.department_id GROUP BY d.name`
