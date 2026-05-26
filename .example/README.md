# 基于 OpenGauss 数据库的分布式锁

> made by 杨星宇

## 环境配置

有几种方式安装 OpenGauss 数据库：

- 使用 Docker
- 参考 [OpenGauss官方指导](https://opengauss.org/zh/quick-start/) 安装

本案例使用 Docker 安装方式，案例目录中已经提供了 `docker-compose.yml` 文件，可以使用 `docker compose up -d` 命令执行。

```yaml
# docker-compose.yml
services:
  opengauss:
    container_name: opengauss
    image: enmotech/opengauss:3.0.0
    restart: always
    privileged: true
    environment:
      - GS_PASSWORD=Root@123456
      - TZ=Asia/Shanghai
    volumes:
      - /data/opengauss:/var/lib/opengauss
    ports:
      - "5432:5432"
```

> **注意**：如果无法拉取镜像，需要配置国内镜像源，配置之后需要重启 docker 加载配置。

## 项目配置

本案例依赖 [opengauss-driver](https://gitcode.com/Cangjie-TPC/opengauss-driver) 和 [stdx](https://gitcode.com/Cangjie/cangjie-stdx-bin) 库， 我们提前构建了 [opengauss-driver](https://gitcode.com/Cangjie-TPC/opengauss-driver) 项目，生成的二进制库放在 `opengauss` 目录下，本案例配置相应的二进制依赖。

```toml
[package]
  cjc-version = "1.0.0"
  name = "demo"
  description = "nothing here"
  version = "1.0.2"
  target-dir = ""
  src-dir = "src"
  output-type = "executable"
  compile-option = "-Woff unused --diagnostic-format=noColor"
  override-compile-option = ""
  link-option = ""
  package-configuration = {}

[dependencies]

[target.x86_64-w64-mingw32]
  [target.x86_64-w64-mingw32.bin-dependencies]
    path-option = ["./opengauss", "../stdx/dynamic/stdx"]
````

当然，您也可以配置 Git 仓依赖，通过源码编译 [opengauss-driver](https://gitcode.com/Cangjie-TPC/opengauss-driver) 

```toml
[dependencies]
  opengauss = {git = "https://gitcode.com/Cangjie-TPC/opengauss-driver.git", branch="master"}
```

---

## 案例场景一：分布式锁

本项目实现了一个基于数据库表的分布式锁 `Locker` 类，通过在数据库中插入和删除锁记录来控制资源的互斥访问。适用于多进程/多实例之间需要同步访问共享资源的场景，依赖数据库的事务和行级锁保证并发安全。

### 表结构

```sql
CREATE TABLE lock_t (
    lock_name VARCHAR(255) PRIMARY KEY, -- 锁的名称，确保唯一
    locked BOOLEAN NOT NULL,            -- 是否被占用
    locked_at TIMESTAMPTZ DEFAULT NOW(),-- 占用时间
    locked_by VARCHAR(255)              -- 占用者标识
);
````

**说明**：

* `lock_name` 是锁的唯一标识（PRIMARY KEY 保证同名锁唯一）。
* `locked` 表示锁状态。
* `locked_at` 记录占用时间，可用于锁超时逻辑。
* `locked_by` 用于区分不同客户端/进程。

### 核心类：`Locker`

#### 构造函数

```cangjie
public Locker(var connector: Connector, var tableName: String)
```

* `connector`：数据库连接器，负责执行 SQL。
* `tableName`：锁表的表名（支持自定义）。
* 初始化 `logger` 用于日志记录。

#### `addLock` 方法

```cangjie
private func addLock(lockName: String, lockedBy: String)
```

* 向锁表插入一条记录，表示当前资源已被 `lockedBy` 占用。
* 通过 `INSERT` 写入 `lock_name`、`locked=true`、当前时间和 `locked_by`。

#### `tryLock` 方法

```cangjie
public func tryLock(lockName: String, lockedBy: String): Bool
```

**流程**：

1. 开启数据库事务。
2. 查询 `lock_name` 是否已存在且 `locked=true`。

   * 如果已被其他 `locked_by` 占用，则返回 `false`（加锁失败）。
3. 如果没有被占用，调用 `addLock` 插入锁记录。
4. 提交事务并返回 `true`。

**异常处理**：

* 如果发生异常，删除当前 `locked_by` 对应的锁记录，避免脏数据。

#### `unLock` 方法

```cangjie
public func unLock(lockName: String, lockeBy: String)
```

* 根据 `lock_name` 和 `locked_by` 删除锁记录，释放锁。

### 并发安全性

* 使用 **数据库事务** 确保 `SELECT` + `INSERT`/`DELETE` 操作的原子性。
* 依赖数据库的 **行级锁** 保证多个客户端并发加锁时的正确性。
* PRIMARY KEY 约束防止重复插入相同锁。

### 适用场景

* 多个进程/线程访问同一资源，需要保证同一时刻只有一个持有锁。
* 分布式系统中无外部分布式锁服务（如 Redis、Zookeeper）时的简易实现。

### 优缺点

**优点**：

* 实现简单，不依赖额外中间件。
* 事务控制方便。

**缺点**：

* 性能依赖数据库，适合低并发锁需求。
* 若锁持有方异常退出，需要额外的锁超时/回收机制。


## 案例场景二：数据库号段式分布式 ID 生成器

在分布式锁基础上，实现了一个**基于数据库号段（Segment）模式**的分布式 ID 生成方案，支持多实例并发安全使用，并通过 `MultiGenerator` 支持多 `IdGenerator` 并行分担压力，避免单原子整数成为性能瓶颈。

适用场景：

- 高性能发号系统
- 多业务类型 ID 分配（通过 `biz_type` 区分）
- 可扩展、低延迟的分布式 ID 生成

### 数据表结构

```sql
CREATE TABLE sequence_id_generator (
    id serial PRIMARY KEY,
    current_max_id bigint NOT NULL, -- 当前已分配的最大 ID
    step integer NOT NULL,          -- 号段长度
    biz_type integer NOT NULL UNIQUE -- 业务类型
);

COMMENT ON COLUMN sequence_id_generator.current_max_id IS '当前最大id';
COMMENT ON COLUMN sequence_id_generator.step IS '号段的长度';
COMMENT ON COLUMN sequence_id_generator.biz_type IS '业务类型';
````

**说明**：

* `biz_type` 用于区分不同业务线的 ID 序列。
* `step` 决定一次批量申请的 ID 数量（号段大小）。
* 数据库的 `FOR UPDATE` 保证多进程/多节点抢号段时的互斥。

### 核心类：`IdGenerator`

#### 配置参数

* **`step`**：每次向数据库申请的号段长度（必须与数据库配置一致）。
* **`slotSize`**：用于 `hash` 分片的槽位数。
* **`threshold`**：预加载阈值（剩余 ID 数量低于 `step * threshold / 10` 时触发异步补充）。
* **`isSupplement`**：原子布尔值，确保同一时间只有一个线程进行号段补充。
* **`id` / `max`**：当前号段的 ID 游标与上限。

#### 工作原理

1. **启动预加载**
   构造函数中立即调用 `supplementId(true)`，防止业务启动后第一次调用时阻塞。

2. **发号**
   `getId()` 使用原子加法获取下一个 ID：

   * 当剩余 ID 数量小于阈值时，异步触发号段补充。
   * 如果当前号段未耗尽，直接返回 ID。
   * 如果耗尽，则阻塞等待补充完成。

3. **号段补充**
   `supplementId()`：

   * 使用原子布尔防止并发补充。
   * 调用 `getIdsFromDB()` 从数据库申请新的号段。
   * 首次启动时设置 `id` 初始值，其余情况仅更新 `max`。

4. **数据库取号段**
   `getIdsFromDB()`：

   * 事务 + `SELECT ... FOR UPDATE` 锁定对应 `biz_type` 行。
   * 检查数据库 `step` 与本地一致性。
   * 更新 `current_max_id` 并返回 `(from, to)` 号段范围。
   * 若 `biz_type` 不存在，自动插入新行。

### 多实例支持：`MultiGenerator`

为解决单个 `IdGenerator` 的原子整数成为性能瓶颈的问题，`MultiGenerator` 维护多个独立的 `IdGenerator` 实例：

```cangjie
public class MultiGenerator {
    private var idGens: Array<IdGenerator>;
    ...
}
```

使用方式：

* **构造**时传入 `size`（实例数量）。
* 客户端可通过哈希路由（`id % size`）选择对应的 `IdGenerator` 获取 ID，从而实现多线程/多节点分流。

### 并发安全保证

* 数据库端：

  * `FOR UPDATE` 行锁保证多节点同时取号段时不会重复。
  * 主键/唯一约束防止业务类型重复。
* 应用端：

  * `AtomicInt64` 保证发号线程安全。
  * `AtomicBool` 控制号段补充的互斥性。

### 优缺点

**优点**：

* 高性能：批量申请号段减少数据库访问频率。
* 可扩展：`MultiGenerator` 支持多路并行发号。
* 并发安全：事务 + 原子操作保证唯一性。

**缺点**：

* 存在号段浪费（实例宕机可能丢弃未用完的 ID）。
* 不支持严格的全局递增（多个实例可能产生交错的 ID 序列）。

````markdown
## 日志配置说明
项目提供了 `setLogger()` 方法，用于配置日志输出等级：

```cangjie
func setLogger() {
    let logger = Default()
    logger.level = LogLevel.ALL
}
````

---

## 遗留问题

* 在 **`LogLevel.ALL`** 等级下，`cangjie` 的 `logger` 在打印某些字段时会出现 **不明错误**。
* 经过分析发现，该问题与 **OpenGauss 驱动** 的日志调用有关。

### 解决方案

* 在 **OpenGauss 驱动**源码中，将出现问题的 **两处 `logger.debug` 调用** 注释掉即可绕过错误。
* 本项目提供的 **OpenGauss 驱动二进制文件** 已经完成了该修改：

  * 注释了两个 `logger.debug` 调用。
  * 在 `LogLevel.ALL` 等级下可正常运行。
* 如果使用其他日志等级（例如 `INFO`、`WARN`），则依然可能触发该不明错误。

### 注意事项

* 推荐在调试和开发阶段使用 **`LogLevel.ALL`** 搭配项目内置的驱动二进制文件。
* 如果从git拉取驱动自行编译，请确保同样注释掉相关的 `logger.debug` 调用，否则可能再次遇到日志打印异常。