# Wrong Question Notebook 部署指南

本指南将帮助你把 Wrong Question Notebook 应用部署到 Vercel。

## 前置条件

1. **Vercel 账户**：在 [vercel.com](https://vercel.com) 注册
2. **Supabase 项目**：在 [supabase.com](https://supabase.com) 创建一个 Supabase 项目
3. **Git 仓库**：将代码推送到 GitHub、GitLab 或 Bitbucket

## 部署前检查清单

✅ **安全审计**：依赖中未发现漏洞
✅ **构建测试**：应用构建成功
✅ **TypeScript**：所有类型错误已解决
✅ **Lint 检查**：代码符合项目规范
✅ **测试**：所有 Vitest 测试套件通过
✅ **配置**：生产就绪的 Next.js 配置

在部署前，从 `web/` 目录运行 `npm run prepush` 以验证所有检查通过。

## 第 1 步：设置 Supabase

1. **创建一个新的 Supabase 项目**：
    - 前往 [supabase.com](https://supabase.com)
    - 点击「New Project」
    - 选择你的组织并创建项目

2. **获取项目凭据**：
    - 前往 Settings → API
    - 复制 Project URL 和 anon/public key

3. **设置数据库结构**（若尚未完成）：
    - 应用期望存在以下表：subjects、problems、tags、attempts、problem sets、review sessions、profiles、user activity logs、admin settings 和 usage quotas
    - 参考你的数据库迁移文件或结构文档

## 第 2 步：部署到 Vercel

### 方案 A：通过 Vercel 控制台部署（推荐）

1. **连接你的仓库**：
    - 前往 [vercel.com/dashboard](https://vercel.com/dashboard)
    - 点击「New Project」
    - 导入你的 Git 仓库

2. **配置项目**：
    - **框架预设**：Next.js
    - **根目录**：`web`（若你的 Next.js 应用位于 web 文件夹）
    - **构建命令**：`npm run build`
    - **输出目录**：`.next`（默认）

3. **设置环境变量**（完整列表参见[环境变量参考](#environment-variables-reference)）：

    ```env
    NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
    NEXT_PUBLIC_SUPABASE_PUBLISHABLE_OR_ANON_KEY=your_supabase_anon_key
    SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
    GEMINI_API_KEY=your_gemini_api_key
    ```

4. **部署**：
    - 点击「Deploy」
    - 等待构建完成

### 方案 B：通过 Vercel CLI 部署

1. **安装 Vercel CLI**：

    ```bash
    npm i -g vercel
    ```

2. **登录 Vercel**：

    ```bash
    vercel login
    ```

3. **进入你的项目目录**：

    ```bash
    cd web
    ```

4. **部署**：

    ```bash
    vercel
    ```

5. **设置环境变量**：

    ```bash
    vercel env add NEXT_PUBLIC_SUPABASE_URL
    vercel env add NEXT_PUBLIC_SUPABASE_PUBLISHABLE_OR_ANON_KEY
    vercel env add SUPABASE_SERVICE_ROLE_KEY
    vercel env add GEMINI_API_KEY
    ```

6. **携带环境变量重新部署**：

    ```bash
    vercel --prod
    ```

## 第 3 步：配置域名（可选）

1. **添加自定义域名**：
    - 前往 Vercel 上的项目控制台
    - 进入 Settings → Domains
    - 添加自定义域名
    - 按照 DNS 配置说明操作

2. **更新环境变量**：
    - 将环境变量中的 `SITE_URL` 更新为你的域名

## 第 4 步：部署后验证

1. **测试应用**：
    - 访问你的部署 URL
    - 测试用户注册与登录（应出现 Turnstile CAPTCHA）
    - 创建笔记本并添加题目
    - 验证文件上传是否正常工作
    - 测试题目复习会话与自动判题
    - 检查统计仪表板是否加载
    - 验证首次访问时出现 Cookie 同意横幅
    - （若为管理员）确认管理面板可访问

2. **检查日志**：
    - 监控 Vercel 函数日志以排查错误
    - 检查 Supabase 日志以排查数据库问题

3. **性能检查**：
    - 运行 Lighthouse 审计
    - 检查 Core Web Vitals

## 环境变量参考

| 变量                                           | 描述                                             | 必填 |
| ---------------------------------------------- | ------------------------------------------------ | ---- |
| `NEXT_PUBLIC_SUPABASE_URL`                     | Supabase 项目 URL                                | 是   |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_OR_ANON_KEY` | Supabase anon / public key                       | 是   |
| `SUPABASE_SERVICE_ROLE_KEY`                    | Supabase service role key（服务端管理员）        | 是   |
| `SITE_URL`                                     | 部署站点 URL（用于生成 sitemap）                 | 否   |
| `GEMINI_API_KEY`                               | Google Gemini API 密钥（用于 AI 题目提取）       | 否   |

## 安全考量

✅ **安全响应头**：已在 `next.config.ts` 中配置安全响应头（HSTS、CSP、X-Frame-Options、X-Content-Type-Options、Referrer-Policy、Permissions-Policy）
✅ **CAPTCHA**：登录和注册表单使用 Cloudflare Turnstile
✅ **HTML 消毒**：DOMPurify + sanitize-html，支持数学内容
✅ **限流**：应用于敏感 API 端点
✅ **输入校验**：Zod 结构校验所有 API 请求体
✅ **CORS**：为 Supabase 正确配置
✅ **身份验证**：Supabase Auth，每次请求均通过中间件刷新会话
✅ **授权**：基于角色的访问控制（user、moderator、admin、super_admin）
✅ **文件上传**：使用 Supabase Storage 与用户作用域访问的安全文件处理
✅ **Cookie 同意**：符合 GDPR 的同意横幅；分析仅在用户选择同意后加载

## 故障排查

### 常见问题

1. **构建失败**：
    - 检查所有环境变量是否已设置
    - 确保 TypeScript 编译在本机通过
    - 确认所有依赖已安装

2. **身份验证问题**：
    - 验证 Supabase URL 与密钥是否正确
    - 检查 Supabase 项目是否处于活动状态
    - 确保 RLS 策略配置正确

3. **文件上传问题**：
    - 验证 Supabase Storage 是否已启用
    - 检查存储桶权限
    - 确保文件大小限制合适

4. **数据库连接问题**：
    - 验证数据库是否可访问
    - 检查连接池设置
    - 查看 Supabase 项目状态

### 获取帮助

- 查看 Vercel 部署日志
- 查看 Supabase 项目日志
- 使用生产环境变量在本地测试
- 查阅 Next.js 与 Supabase 文档

## 监控与维护

1. **设置监控**：
    - 已集成 Vercel Analytics 与 Speed Insights（在 Cookie 同意后按条件加载）
    - 如需要，可设置错误追踪（Sentry 等）
    - 监控 Supabase 用量与限额
    - 检查管理面板的统计仪表板以查看平台级指标

2. **定期维护**：
    - 保持依赖更新
    - 监控安全公告
    - 定期审查并轮换 API 密钥

## 生产优化

应用包含多项生产优化：

- **图片优化**：Next.js Image 组件，支持 WebP/AVIF
- **打包优化**：针对 lucide-react 优化的包导入
- **安全响应头**：HSTS、X-Frame-Options、X-Content-Type-Options、CSP、Referrer-Policy、Permissions-Policy
- **SEO**：通过 `next-sitemap`（在 `postbuild` 时运行）自动生成 sitemap 与 robots.txt
- **条件式分析**：Vercel Analytics 与 Speed Insights 仅在 Cookie 同意后加载
- **Turbopack**：开发环境用于加速重新构建（Next.js 16）

## 支持

针对本应用的具体问题，请查看项目的 GitHub 仓库或联系开发团队。
