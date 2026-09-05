# 问题追踪器：GitHub

本仓库的问题与规范以 GitHub issue 形式存在。所有操作使用 `gh` 命令行。

## 约定

- **创建问题**：`gh issue create --title "..." --body "..."`。多行正文使用 heredoc。
- **读取问题**：`gh issue view <number> --comments`，用 `jq` 过滤评论并同时获取标签。
- **列出问题**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，配合适当的 `--label` 和 `--state` 过滤条件。
- **评论问题**：`gh issue comment <number> --body "..."`
- **添加 / 移除标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭**：`gh issue close <number> --comment "..."`

仓库从 `git remote -v` 推断——在克隆目录内运行 `gh` 会自动完成。

## 将拉取请求作为分诊入口

**PR 作为请求入口：否。**（若本仓库将外部 PR 视为功能请求，改为 `yes`；`/triage` 会读取此标记。）

当设为 `yes` 时，PR 与 issue 走相同的标签与状态流程，使用对应的 `gh pr` 命令：

- **读取 PR**：`gh pr view <number> --comments`，查看差异用 `gh pr diff <number>`。
- **列出待分诊的外部 PR**：`gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`，然后只保留 `authorAssociation` 为 `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR` 或 `NONE` 的条目（剔除 `OWNER`/`MEMBER`/`COLLABORATOR`）。
- **评论 / 打标签 / 关闭**：`gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub 中 issue 与 PR 共享同一编号空间，所以裸的 `#42` 可能是其中任意一种——用 `gh pr view 42` 判断，失败则回退到 `gh issue view 42`。

## 当技能说「发布到问题追踪器」

创建一个 GitHub issue。

## 当技能说「获取相关工单」

运行 `gh issue view <number> --comments`。

## 寻路操作

供 `/wayfinder` 使用。**地图**是一个单独的问题，**子问题**作为工单。

- **地图**：一个标记为 `wayfinder:map` 的 issue，正文承载 Notes / Decisions-so-far / Fog。创建命令：`gh issue create --label wayfinder:map`。
- **子工单**：作为 GitHub 子 issue（sub-issue，通过 sub-issues 端点的 `gh api`）链接到地图的 issue。若未启用子 issue，则在地图正文的任务列表中添加工单，并在子工单正文顶部写上 `Part of #<map>`。标签为 `wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。被认领后，工单分配给负责开发的工程师。
- **阻塞关系**：使用 GitHub **原生 issue 依赖**——这是规范且 UI 可见的表示方式。用 `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>` 添加边，其中 `<blocker-db-id>` 是阻塞者的数字**数据库 id**（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`，不是 `#number` 或 `node_id`）。GitHub 通过 `issue_dependencies_summary.blocked_by` 报告阻塞状态（仅统计未关闭的阻塞者——这是实时门控）。若依赖不可用，回退到在子工单正文顶部写 `Blocked by: #<n>, #<n>`。当所有阻塞者都关闭时，工单解除阻塞。
- **前沿查询**：列出地图中未关闭的子问题（`gh issue list --state open`，限定在地图的子 issue / 任务列表内），剔除带有未关闭阻塞者（`issue_dependencies_summary.blocked_by > 0`，或 `Blocked by` 行中有未关闭 issue）或已有指派人的工单；地图顺序中第一个胜出。
- **认领**：`gh issue edit <n> --add-assignee @me`——会话的第一次写入。
- **解决**：`gh issue comment <n> --body "<answer>"`，然后 `gh issue close <n>`，最后在地图的 Decisions-so-far 中追加一条上下文指针（gist + 链接）。
