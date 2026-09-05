# 领域文档

工程技能在探索代码库时，应如何消费本仓库的领域文档。

## 探索前先阅读

- 仓库根目录的 **`CONTEXT.md`**，或
- 仓库根目录的 **`CONTEXT-MAP.md`**（若存在）——它指向每个上下文对应的一个 `CONTEXT.md`。阅读与你主题相关的每一个。
- **`docs/adr/`**——阅读与你即将工作的领域相关的 ADR。在多上下文仓库中，还要检查 `src/<context>/docs/adr/` 中上下文范围内的决策。

如果这些文件不存在，**静默继续**。不要指出它们缺失，也不要建议预先创建。`/domain-modeling` 技能（通过 `/grill-with-docs` 和 `/improve-codebase-architecture` 触发）会在术语或决策真正被解决时按需创建它们。

## 文件结构

单上下文仓库（大多数仓库）：

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

多上下文仓库（根目录存在 `CONTEXT-MAP.md`）：

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← 系统级决策
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← 上下文专属决策
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## 使用词汇表中的术语

当你的输出中命名领域概念时（issue 标题、重构提案、假设、测试名称），使用 `CONTEXT.md` 中定义的术语。不要偏向词汇表明确回避的同义词。

如果你需要的概念尚未收录在词汇表中，这是一个信号——要么你在发明项目并不使用的语言（请重新考虑），要么存在真正的空缺（记下来交给 `/domain-modeling`）。

## 标记 ADR 冲突

如果你的输出与现有 ADR 矛盾，请明确指出而不是静默覆盖：

> _与 ADR-0007（事件溯源订单）矛盾——但值得重新讨论，因为……_
