# Wrong Question Notebook (WQN)

一款面向学生的 Web 应用，用于记录错题、按科目组织并跟踪长期掌握进度。基于 Next.js、Supabase 与 Tailwind CSS 构建。

## 项目结构

所有应用代码位于 `web/`：

```txt
web/
  app/              # Next.js App Router 页面与 API 路由
    (app)/          # 已认证的应用页面（subjects、problem-sets、tags 等）
    auth/           # 认证页面（login、sign-up、forgot-password 等）
    api/            # API 路由处理器
    page.tsx        # 落地页（公开）
    layout.tsx      # 根布局（Geist 字体、ThemeProvider、分析）
    globals.css     # 全局样式、CSS 工具类、关键帧动画
  components/
    ui/             # shadcn/ui 基础组件（Button、Card、Dialog、Input 等）
    landing/        # 落地页组件（hero-animation.tsx）
    navigation.tsx  # 共享导航栏
    ...             # 功能专属组件
  lib/              # 工具函数、Supabase 客户端、结构、类型
```

## 技术栈

- **框架：** Next.js 16（App Router、Turbopack 开发）
- **语言：** TypeScript（严格模式）
- **样式：** Tailwind CSS 3 + `tailwindcss-animate`
- **组件：** shadcn/ui（Radix UI 基础组件 + CVA）
- **图标：** lucide-react
- **字体：** Geist（通过 `next/font/google`）
- **认证/数据库：** Supabase（SSR 客户端）
- **主题：** `next-themes`，`class` 策略，默认跟随系统
- **富文本：** TipTap 编辑器 + KaTeX 数学渲染
- **格式化：** Prettier（单引号、2 空格缩进、LF 行尾、80 字符宽度）
- **Lint：** ESLint 搭配 prettier 插件

## 命令

在 `web/` 下运行：

| 命令                 | 用途                                             |
| -------------------- | ------------------------------------------------ |
| `npm run dev`        | 启动开发服务器（Turbopack）                      |
| `npm run build`      | 生产构建                                         |
| `npm run type-check` | TypeScript 检查（`tsc --noEmit`）                |
| `npm run lint`       | ESLint 检查                                      |
| `npm run fix-all`    | 自动修复 lint + 格式                             |
| `npm run prepush`    | 完整检查：fix-all、type-check、lint、format-check、build |

提交前务必运行 `npm run prepush` 以发现问题。

## 更新日志

项目在 `CHANGELOG.md` 中维护更新日志，遵循 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 格式。实现功能、修复或显著变更时**务必更新日志**：

- 在 `## [Unreleased]` 下按对应分类添加条目：`Added`、`Changed`、`Deprecated`、`Removed`、`Fixed`、`Security`
- 将相关变更归组在加粗的功能名（如 `- **功能名**`）下，用子条目补充细节
- 条目保持简洁但足够描述性，让读日志的人能理解改了什么
- 不包含纯内部重构或依赖升级，除非影响用户可见行为

---

## UI 设计指南

落地页（`web/app/page.tsx`）是 WQN 视觉身份的权威参考。产品中所有 UI 工作都应遵循这些约定。

### 设计基调

WQN 的视觉语言是**俏皮与温暖**——对学子友好，而非企业风。想象书桌上的笔记本，而不是企业仪表板。

关键特征：

- **暖色调**取代冷/中性色：琥珀、橙、玫瑰为主强调色；蓝与绿为次要色
- **大方圆角**：卡片与容器用 `rounded-2xl`，按钮与图标用 `rounded-xl`，徽章/药丸用 `rounded-full`
- **柔和层次**：浅投影（`shadow-sm`、`shadow-md`）、低透明度细边框（`border-amber-200/40`）
- **笔记本隐喻**：横线背景、纸张质感、铅笔/钢笔图标（lucide-react 的 `NotebookPen`）
- **无生硬对比**：背景与边框使用透明度修饰符（`/80`、`/50`、`/30`）保持柔和

### 色彩系统

#### 浅色模式背景

- **页面级渐变：** `from-amber-50/80 via-white to-rose-50/50`（暖色着色，非纯白）
- **分区色带：** 交替分区用 `bg-amber-50/50`
- **卡片填充：** 每个功能各自的渐变 `from-{color}-50 to-{color}-100/50`（如 `from-blue-50 to-blue-100/50`）
- **图标容器：** `bg-{color}-500/10`（极淡着色）

#### 深色模式背景

- **页面级：** `dark:from-gray-900 dark:via-gray-900 dark:to-gray-900`（平面深色，无渐变）
- **分区色带：** `dark:bg-gray-800/30`
- **卡片填充：** `dark:from-{color}-950/40 dark:to-{color}-900/20`
- **图标容器：** `dark:bg-{color}-500/20`

#### 文本颜色

- **标题：** `text-gray-900 dark:text-white`
- **正文：** `text-gray-600 dark:text-gray-400`
- **弱化/说明文字：** `text-gray-500 dark:text-gray-400`
- **彩色强调：** 浅色模式用 `{color}-600` / 深色模式用 `{color}-400`（如 `text-amber-600 dark:text-amber-400`）

#### 边框

- **卡片/容器：** `border-{color}-200/40 dark:border-{color}-800/30`（低透明度、着色）
- **分隔线：** `border-amber-200/30 dark:border-gray-800`

#### 暖色强调色板（用于功能区分）

| 用途               | 浅色      | 深色      |
| ------------------ | --------- | --------- |
| 主暖色             | amber-600 | amber-400 |
| 次暖色             | orange-600| orange-400|
| 第三暖色           | rose-600  | rose-400  |
| 信息 / 组织        | blue-600  | blue-400  |
| 成功 / 进度        | green-600 | green-400 |

### 排版

字体为 **Geist**（全局加载，无需按组件设置字体）。

- **首屏主标题：** 使用 `landing-hero-title` 类
- **分区标题：** 使用 `landing-section-title` 类
- **分区副标题：** 使用 `landing-section-subtitle` 类
- **卡片标题：** 使用 `landing-card-title` 类
- **卡片正文：** 使用 `landing-card-text` 类
- **步骤标签：** 使用 `landing-step-label` 类（通过 `text-{color}-600 dark:text-{color}-400` 按步骤加色）
- **标签/徽章：** 药丸徽章用 `text-sm font-medium`
- **渐变文本：** 强调短语用 `text-gradient-warm` 类（琥珀 → 橙 → 玫瑰）

### 组件模式

以下所有可复用模式在 `globals.css` 中都有对应 CSS 类。使用这些类，而非重复书写原始 Tailwind 工具类。

#### 分区布局

```html
<section className="landing-section {optional-bg}">
    <div className="landing-section-inner">
        <!-- max-w-6xl；若需更窄可覆盖为 max-w-5xl/3xl -->
        <div className="landing-section-header">
            <h2 className="landing-section-title">...</h2>
            <p className="landing-section-subtitle">...</p>
        </div>
        {content}
    </div>
</section>
```

#### 页面背景

在 `<main>` 元素上使用 `landing-page-bg`，获得支持深色模式的暖琥珀到玫瑰渐变。

#### 功能卡片（bento 网格）

```html
<div
    className="landing-card from-{color}-50 to-{color}-100/50 dark:from-{color}-950/40 dark:to-{color}-900/20 border-{color}-200/40 dark:border-{color}-800/30"
>
    <div className="landing-icon-box bg-{color}-500/10 dark:bg-{color}-500/20">
        <Icon className="w-6 h-6 text-{color}-600 dark:text-{color}-400" />
    </div>
    <div className="space-y-2">
        <h3 className="landing-card-title">...</h3>
        <p className="landing-card-text">...</p>
    </div>
</div>
```

`landing-card` 提供共享结构（rounded-2xl、内边距、flex 布局、`bg-gradient-to-br`、`border`）。每张卡片添加颜色专属的 `from-`/`to-`/`border-` 工具类。三列网格中的宽卡片使用 `lg:col-span-2`。

#### 图标容器

使用 `landing-icon-box` 并添加颜色：`bg-{color}-500/10 dark:bg-{color}-500/20`。
内部图标：`w-6 h-6 text-{color}-600 dark:text-{color}-400`。

#### 药丸徽章（贴纸风格）

```txt
inline-flex items-center gap-2 rounded-full bg-amber-100/80 dark:bg-amber-900/30
px-4 py-1.5 text-sm font-medium text-amber-800 dark:text-amber-300
border border-amber-200/50 dark:border-amber-800/40
```

更换色系（amber、rose、blue 等）以改变徽章主题。（未抽取为类，因为颜色须按实例变化。）

#### 按钮（CTA 风格）

```html
<button asChild size="lg" className="btn-cta-primary">
    <!-- 主按钮：带投影 -->
    <button asChild variant="outline" size="lg" className="btn-cta">
        <!-- 次按钮：无投影 -->
    </button>
</button>
```

`btn-cta` = 共享尺寸/圆角（`text-base px-7 py-5 rounded-xl`）。`btn-cta-primary` 在此基础上加 `shadow-md`。

### 深色模式

每个视觉元素都必须有对应的 `dark:` 变体。模式保持一致：

- 浅色暖色着色（amber-50、rose-50）变为深色弱化色调（gray-800/30、{color}-950/40）
- 浅色文本（gray-900）变为白色；正文（gray-600）变为 gray-400
- 深色模式中边框进一步降低透明度（`/30` 而非 `/40`）
- 深色模式中渐变扁平化（单一深色调，而非多色渐变）

### 动画

动画位于 `globals.css`，以 `@keyframes` 规则配合 `@layer components` 中对应的工具类。

命名约定：落地页动画使用 `hero-` 前缀。其他页面使用描述性前缀（如 `card-`、`page-`）。

交错入场动画模式：

1. 定义基础关键帧（如 `heroSlideInRight`）
2. 创建递增延迟的 CSS 类：`0.6s`、`0.9s`、`1.2s`
3. 使用 `animation: {name} {duration} ease-out {delay} both`（`both` 填充模式很重要）

动画保持微妙：小位移（8-24px）、短时长（0.4-0.8s）、`ease-out` 缓动。

### 服务端组件与客户端组件

- 需要 Supabase 认证检查的页面（`page.tsx`）保持为**异步服务端组件**
- 交互式/动画 UI 抽取到子目录中的**独立客户端组件**（`'use client'`）（如 `components/landing/`）
- 这样既能保持页面服务端渲染，又允许客户端交互

### 现有 CSS 工具类

定义于 `globals.css` 的 `@layer components` 下。优先使用这些类，而非重新发明：

**通用工具类：**

| 类                                                       | 用途                                                             |
| -------------------------------------------------------- | ---------------------------------------------------------------- |
| `text-gradient`                                          | 蓝到靛蓝渐变文本                                                 |
| `text-gradient-warm`                                     | 琥珀到橙到玫瑰渐变文本                                           |
| `glass-effect`                                           | 磨砂玻璃背景（`bg-white/80 backdrop-blur-sm`）                   |
| `shadow-soft`                                            | 柔和投影（`shadow-lg shadow-black/5`）                           |
| `ruled-lines`                                            | 笔记本横线重复背景                                               |
| `heading-xl` 至 `heading-xs`                             | 排版字号（应用页面）                                             |
| `text-body-lg`、`text-body`、`text-body-sm`              | 正文字号                                                         |
| `page-container`                                         | 标准应用页宽度 + 内边距（`max-w-6xl mx-auto px-4 py-6`）         |
| `status-mastered`、`status-wrong`、`status-needs-review` | 题目状态徽章                                                     |

**落地页 / 营销页类：**

| 类                        | 用途                                                                 |
| -------------------------- | -------------------------------------------------------------------- |
| `landing-page-bg`          | 带深色模式的暖琥珀到玫瑰页面渐变                                     |
| `landing-section`          | 全宽分区，`py-20`                                                     |
| `landing-section-inner`    | 居中内容容器（`max-w-6xl mx-auto px-6`）                              |
| `landing-section-header`   | 带底部边距的居中头部组                                               |
| `landing-section-title`    | 分区标题（`text-3xl md:text-4xl font-bold`），带颜色                  |
| `landing-section-subtitle` | 分区副标题（`text-lg`），弱化颜色 + max-width                          |
| `landing-hero-title`       | 首屏主标题，响应式字号与紧凑行距                                     |
| `landing-card`             | Bento 卡片基础：rounded-2xl、内边距、flex 布局、渐变背景 + 边框      |
| `landing-card-title`       | 卡片标题（`text-xl font-semibold`），带颜色                           |
| `landing-card-text`        | 卡片正文，弱化颜色与宽松行距                                         |
| `landing-icon-box`         | 48px 圆角图标容器（按需添加 `bg-{color}`）                            |
| `landing-step-label`       | 编号步骤的大写粗体标签（按需添加颜色）                               |
| `btn-cta`                  | CTA 按钮尺寸：`text-base px-7 py-5 rounded-xl`                        |
| `btn-cta-primary`          | 在 `btn-cta` 基础上加 `shadow-md`，用于主操作                        |

### UI 变更检查清单

构建或重新设计任何页面/组件时：

1. **先读落地页**（`web/app/page.tsx`）吸收当前视觉模式
2. **默认使用暖色**——琥珀/橙/玫瑰，而非冷灰或蓝
3. **应用大方圆角**——容器 `rounded-2xl`，交互元素 `rounded-xl`
4. **始终提供深色模式**——每个 `bg-`、`text-`、`border-` 类都需要 `dark:` 对应
5. **背景与边框使用透明度修饰符**（`/80`、`/50`、`/30`）保持柔和
6. **动画保持微妙**——小变换、短时长、`ease-out`
7. **页面需保持服务端组件时抽取客户端组件**
8. **先复用 `globals.css` 中现有 CSS 类**，再写新的
9. **使用 lucide-react 图标**——与应用其余部分保持一致
10. **完成后在 `web/` 运行 `npm run prepush`** 验证一切通过
