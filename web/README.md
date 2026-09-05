<a href="https://demo-nextjs-with-supabase.vercel.app/">
  <img alt="Next.js 与 Supabase Starter Kit——使用 Next.js 与 Supabase 构建应用的最快方式" src="https://demo-nextjs-with-supabase.vercel.app/opengraph-image.png">
  <h1 align="center">Next.js 与 Supabase Starter Kit</h1>
</a>

<p align="center">
 使用 Next.js 与 Supabase 构建应用的最快方式
</p>

<p align="center">
  <a href="#features"><strong>功能特性</strong></a> ·
  <a href="#demo"><strong>演示</strong></a> ·
  <a href="#deploy-to-vercel"><strong>部署到 Vercel</strong></a> ·
  <a href="#clone-and-run-locally"><strong>克隆并在本地运行</strong></a> ·
  <a href="#feedback-and-issues"><strong>反馈与问题</strong></a>
  <a href="#more-supabase-examples"><strong>更多示例</strong></a>
</p>
<br/>

## 功能特性

- 覆盖整个 [Next.js](https://nextjs.org) 技术栈
  - App Router
  - Pages Router
  - Middleware
  - Client
  - Server
  - 开箱即用！
- supabase-ssr：用于配置 Supabase Auth 使用 Cookie 的包
- 通过 [Supabase UI Library](https://supabase.com/ui/docs/nextjs/password-based-auth) 安装的密码认证模块
- 使用 [Tailwind CSS](https://tailwindcss.com) 进行样式设计
- 使用 [shadcn/ui](https://ui.shadcn.com/) 组件
- 可选地通过 [Supabase Vercel 集成与 Vercel 部署](#deploy-your-own)
  - 环境变量自动分配到 Vercel 项目

## 演示

你可以在 [demo-nextjs-with-supabase.vercel.app](https://demo-nextjs-with-supabase.vercel.app/) 查看完整可用的演示。

## 部署到 Vercel

Vercel 部署会引导你创建 Supabase 账户与项目。

安装 Supabase 集成后，所有相关环境变量都会分配到项目，使部署完全可用。

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fvercel%2Fnext.js%2Ftree%2Fcanary%2Fexamples%2Fwith-supabase&project-name=nextjs-with-supabase&repository-name=nextjs-with-supabase&demo-title=nextjs-with-supabase&demo-description=This+starter+configures+Supabase+Auth+to+use+cookies%2C+making+the+user%27s+session+available+throughout+the+entire+Next.js+app+-+Client+Components%2C+Server+Components%2C+Route+Handlers%2C+Server+Actions+and+Middleware.&demo-url=https%3A%2F%2Fdemo-nextjs-with-supabase.vercel.app%2F&external-id=https%3A%2F%2Fgithub.com%2Fvercel%2Fnext.js%2Ftree%2Fcanary%2Fexamples%2Fwith-supabase&demo-image=https%3A%2F%2Fdemo-nextjs-with-supabase.vercel.app%2Fopengraph-image.png)

以上操作还会将 Starter Kit 克隆到你的 GitHub，你可以将其克隆到本地进行本地开发。

如果你只想在本地开发而不部署到 Vercel，[请按以下步骤操作](#clone-and-run-locally)。

## 克隆并在本地运行

1. 你首先需要一个 Supabase 项目，可通过 [Supabase 控制台](https://database.new) 创建

2. 使用 Supabase Starter 模板的 npx 命令创建 Next.js 应用

   ```bash
   npx create-next-app --example with-supabase with-supabase-app
   ```

   ```bash
   yarn create next-app --example with-supabase with-supabase-app
   ```

   ```bash
   pnpm create next-app --example with-supabase with-supabase-app
   ```

3. 使用 `cd` 进入应用的目录

   ```bash
   cd with-supabase-app
   ```

4. 将 `.env.example` 重命名为 `.env.local` 并更新以下内容：

   ```
   NEXT_PUBLIC_SUPABASE_URL=[INSERT SUPABASE PROJECT URL]
   NEXT_PUBLIC_SUPABASE_ANON_KEY=[INSERT SUPABASE PROJECT API ANON KEY]
   ```

   `NEXT_PUBLIC_SUPABASE_URL` 和 `NEXT_PUBLIC_SUPABASE_ANON_KEY` 都可在[你的 Supabase 项目的 API 设置](https://supabase.com/dashboard/project/_?showConnect=true)中找到

5. 现在可以运行 Next.js 本地开发服务器：

   ```bash
   npm run dev
   ```

   Starter Kit 现在应该运行在 [localhost:3000](http://localhost:3000/) 上。

6. 此模板预置了默认的 shadcn/ui 样式。如果你想要其他 ui.shadcn 样式，请删除 `components.json` 并[重新安装 shadcn/ui](https://ui.shadcn.com/docs/installation/next)

> 也可参阅[本地开发文档](https://supabase.com/docs/guides/getting-started/local-development)以在本地运行 Supabase。

## 反馈与问题

请在 [Supabase GitHub 组织](https://github.com/supabase/supabase/issues/new/choose)提交反馈与问题。

## 更多 Supabase 示例

- [Next.js 订阅支付 Starter](https://github.com/vercel/nextjs-subscription-payments)
- [基于 Cookie 的认证与 Next.js 13 App Router（免费课程）](https://youtube.com/playlist?list=PL5S4mPUpp4OtMhpnp93EFSo42iQ40XjbF)
- [Supabase Auth 与 Next.js App Router](https://github.com/supabase/supabase/tree/master/examples/auth/nextjs)
